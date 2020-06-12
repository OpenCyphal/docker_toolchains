# Texer Docker

Builds and pushes a docker environment used by the UAVCAN project to build [LaTeX](https://www.latex-project.org/) documents.

## Build and Push

These instructions are for maintainers with permissions to push to the "uavcan" organization on Docker Hub.

```bash
docker build .
```

```bash
docker images

REPOSITORY      TAG            IMAGE ID
texer           latest         d7ab132649d6
```

```bash
docker tag d7ab132649d6 uavcan/texer:ubuntu-18.04
docker tag d7ab132649d6 uavcan/texer:latest
docker login --username=yourhubusername
docker push uavcan/texer:ubuntu-18.04
docker push uavcan/texer:latest
```

## Testing out the container

Start an interactive session:

```bash
docker run --rm -it -v ${PWD}:/repo uavcan/texer:ubuntu-18.04
```

On macintosh you'll probably want to optimize osxfs with something like cached or delegated:

```bash
docker run --rm -it -v ${PWD}:/repo:delegated uavcan/texer:ubuntu-18.04
```

See ["Performance tuning for volume mounts"](https://docs.docker.com/docker-for-mac/osxfs-caching/) for details.

## Travis CI

You can use this in your .travis.yml like this:

```none
services:
  - docker

before_install:
- docker pull uavcan/texer:ubuntu-18.04

script:
- docker run --rm -v $TRAVIS_BUILD_DIR:/repo uavcan/uavcan/texer:ubuntu-18.04 /bin/sh -c ./compile.sh

```

## BuildKite

Example pipeline.yml:

```yaml
- label: ":github: my containerized build"
    command: "compile"
    plugins:
      - docker#v3.5.0:
          workdir: /repo
          image: "uavcan/texer:ubuntu-18.04"
          propagate-environment: true
          mount-ssh-agent: true
```
