# "Nodethon" (Node.js + Python) Docker

Builds and pushes a docker environment useful for testing and building Node.js applications that also use Python or Python applications that also use Node.js. This environment contains Node.js and a few other, essential JavaScript dependencies as well as series of python versions allowing multi-version tox testing locally and in CI services.

All *nodethon* images include the ["sonarqube"](https://www.sonarqube.org) scanner. This scanner allows node and tox builds to upload coverage and analysis reports to a sonarqube instance.

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
docker tag d7ab132649d6 uavcan/nodethon:node13-py37-py38
docker login --username=yourhubusername
docker push uavcan/nodethon:node13-py37-py38
```

## Testing out the container

Start an interactive session:

```bash
docker run --rm -it -v ${PWD}:/repo uavcan/nodethon:node13-py37-py38
```

On MacOS you'll probably want to optimize `osxfs` with something like cached or delegated:

```bash
docker run --rm -it -v ${PWD}:/repo:delegated uavcan/nodethon:node13-py37-py38
```

See ["Performance tuning for volume mounts"](https://docs.docker.com/docker-for-mac/osxfs-caching/) for details.

## Travis CI

You can use this in your .travis.yml like this:

```none
services:
  - docker

before_install:
- docker pull uavcan/nodethon:node13-py37-py38

script:
- docker run --rm -v $TRAVIS_BUILD_DIR:/repo uavcan/nodethon:node13-py37-py38 /bin/sh -c tox

```

## BuildKite

Example pipeline.yml:

```yaml
- label: ":github: my containerized build"
    command: "nodethon tox"
    plugins:
      - docker#v3.5.0:
          workdir: /repo
          image: "uavcan/nodethon:node13-py37-py38"
          propagate-environment: true
          mount-ssh-agent: true
```
