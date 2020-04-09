# "Nodethon" (Node.js + Python) Docker

Builds and pushes a docker environment for use with tox testing. This environment contains Node.js 13 and some other JavaScript dependencies, besides a series of python versions allowing multi-version tox testing locally and in CI services.

The "sq" suffix indicates that the ["sonarqube"](https://www.sonarqube.org) scanner has been included in the image. This scanner allows tox builds to upload coverage and other reports to a sonarqube instance.

## Build and Push

These instructions are for maintainers with permissions to push to the "uavcan" organization on Docker Hub.

```
docker build .
```
```
docker images

REPOSITORY      TAG            IMAGE ID
nodethon        latest         d7ab132649d6
```
```
# We use the range of python environments supported as the version tag.
docker tag d7ab132649d6 uavcan/nodethon:py35-py38-node13-sq
docker login --username=yourhubusername
docker push uavcan/nodethon:py35-py38-node13-sq
```

## Testing out the container

Start an interactive session:

```bash
docker run --rm -it -v ${PWD}:/repo uavcan/nodethon:py35-py38-node13-sq
```

On MacOS you'll probably want to optimize `osxfs` with something like cached or delegated:

```bash
docker run --rm -it -v ${PWD}:/repo:delegated uavcan/nodethon:py35-py38-node13-sq
```

See ["Performance tuning for volume mounts"](https://docs.docker.com/docker-for-mac/osxfs-caching/) for details.

## Travis CI

You can use this in your .travis.yml like this:

```none
services:
  - docker

before_install:
- docker pull uavcan/nodethon:py35-py38-node13-sq

script:
- docker run --rm -v $TRAVIS_BUILD_DIR:/repo uavcan/nodethon:py35-py38-node13-sq /bin/sh -c tox

```

## BuildKite

Example pipeline.yml:

```yaml
- label: ":github: my containerized build"
    command: "nodethon tox"
    plugins:
      - docker#v3.5.0:
          workdir: /repo
          image: "uavcan/nodethon:py35-py38-node13-sq"
          propagate-environment: true
          mount-ssh-agent: true
```
