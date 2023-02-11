![OpenCyphal](opencyphal_logo.svg) OpenCyphal Containerized Toolchains
===================

This repository contains the Dockerfiles, instructions, and some utilities for
building containers to be used as common toolchains and development environments
for OpenCyphal projects. These containers are published to the [opencyphal
organization on Github](https://github.com/orgs/OpenCyphal/packages) and are used
by the build automation for OpenCyphal projects. You can use these same
containers to get consistent build results in your local development environment.

### opencyphal/c_cpp

[![ghcr.io/opencyphal/c_cpp container build and publish.](https://github.com/OpenCyphal/docker_toolchains/actions/workflows/c_cpp.yml/badge.svg)](https://github.com/OpenCyphal/docker_toolchains/actions/workflows/c_cpp.yml)

The [Open Cyphal c_cpp
container](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/c_cpp)
is based on various Ubuntu releases with the container tag being the latest build
of our c_cpp container based on a given release. This container provides the
necessary compilers and utilities to build and run OpenCyphal C or C++ projects
like [libcanard](https://github.com/OpenCyphal/libcanard) and
[Nunavut](https://github.com/OpenCyphal/nunavut).

#### Supported Versions

| tag      | Python | Gcc | Clang | Cmake | Other Utilities |
|----------|--------|-----|-------|-------|-------|
| [ubuntu-20.04](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/c_cpp/69896735?tag=ubuntu-20.04) | 3.10 | 9.3.0 | 10.0.0 | 3.16.3 | <ul><li>qemu</li><li>can-utils</li><li>sonar-scanner</li></ul> |

### opencyphal/texer

 [LaTeX](https://www.latex-project.org/) toolchain. Will be migrated to github actions soon, stay tuned!

 ### opencyphal/toxic

 Python toolchain. Will be migrated to github actions soon. Stay tuned!
