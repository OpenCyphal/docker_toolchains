# C/C++ Toolchain Docker

The `opencyphal/c_cpp` docker image provides a consistent build and test environment
for development, continuous-integration, and test automation of C and C++ based projects.

## Official Release

To release a new build of this container simply create a [new github release](https://github.com/OpenCyphal/docker_toolchains/releases/new)
that starts with the ubuntu version container you want to release and ends with "-c_cpp". For example `v20.04-c_cpp`
will cause the github workflow to rebuild and push the `opencyphal/c_cpp:ubuntu-20.04` container.

## Manual Build and Push

These instructions are for maintainers with permissions to push to the
[OpenCyphal organization on Github](https://github.com/OpenCyphal/). Normally the container should be published by
a github action but these instructions provide a way to manually update the container from any developer environment.

First create a temporary (7-day expiration please) personal access token (classic) with write:packages and read:packages
scope. See [this github help page](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for instructions.

Next, make sure you can login:

```bash
export FGP = (fine-grained permission for OpenCyphal organization)
echo $FGP | docker login ghcr.io -u (github username) --password-stdin
```

... now build:

```bash
docker build -t ghcr.io/opencyphal/c_cpp:ubuntu-20.04 .
```

... and finally, push.

```bash
docker push ghcr.io/opencyphal/c_cpp:ubuntu-20.04
```

## Testing out the container

To login to an interactive session do:

```bash
docker run --rm -it -v ${PWD}:/repo ghcr.io/opencyphal/c_cpp:ubuntu-20.04
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
  -Dsonar.organization=OpenCyphal \
  -Dsonar.projectKey=OpenCyphal_myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.cfamily.build-wrapper-output=bw-output \
  -Dsonar.login=TOKEN
```

A [CMake example on github](https://github.com/SonarSource/sonarcloud_example_cpp-cmake-linux-otherci)
