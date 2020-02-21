# C/C++ Toolchain Docker

The `uavcan/c_cpp` docker image provides a consistent build and test environment
for development, continuous-integration, and test automation of C and C++ based projects.

## Manual Build and Push

These instructions are for maintainers with permissions to push to the [uavcan organization on Docker Hub](https://cloud.docker.com/u/uavcan).

```bash
docker build .
```

```bash
docker images

REPOSITORY   TAG      IMAGE ID       CREATED              SIZE
<none>       <none>   736647481ad3   About a minute ago   1GB
```

```bash
docker tag 736647481ad3 uavcan/c_cpp:ubuntu-18.04
docker login --username=yourhubusername
docker push uavcan/c_cpp:ubuntu-18.04
```

Use this pattern for tags:

```bash
uavcan/[toolchain]:[build environment]
```

## Testing out the container

To login to an interactive session do:

```bash
docker run --rm -it -v ${PWD}:/repo uavcan/c_cpp:ubuntu-18.04
```

## Toolchain Documentation

### Sonarqube

Wrap yer build:

```bash
build-wrapper-linux-x86-64 --out-dir build_wrapper_output_directory cmake --build build/
```

Upload the results:

```bash
sonar-scanner \
  -Dsonar.organization=uavcan \
  -Dsonar.projectKey=UAVCAN_myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.cfamily.build-wrapper-output=bw-output \
  -Dsonar.login=TOKEN
```

A [CMake example on github](https://github.com/SonarSource/sonarcloud_example_cpp-cmake-linux-otherci)

## Travis CI

You can use this in your .travis.yml like this:

```none
services:
  - docker

before_install:
- docker pull uavcan/c_cpp:ubuntu-18.04

script:
- docker run --rm -v $TRAVIS_BUILD_DIR:/repo uavcan/c_cpp:ubuntu-18.04 /bin/sh -c mybuild_command

```

## BuildKite

Example pipeline.yml:

```yaml
- label: ":github: my containerized build"
    command: "my_build_command"
    plugins:
      - docker#v3.5.0:
          workdir: /repo
          image: "uavcan/c_cpp:ubuntu-18.04"
          propagate-environment: true
          mount-ssh-agent: true
```
