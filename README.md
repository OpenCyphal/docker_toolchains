![OpenCyphal](opencyphal_logo.svg) OpenCyphal Containerized Toolchains
===================

This repository contains the Dockerfiles, instructions, and some utilities for
building containers to be used as common toolchains and development environments
for OpenCyphal projects. These containers are published to the [opencyphal
organization on Github](https://github.com/orgs/OpenCyphal/packages) and are used
by the build automation for OpenCyphal projects. You can use these same
containers to get consistent build results in your local development environment.

To allow hosting of multiple container builds from a single repo each toolchain container
is assigned a prefix. For every release event in this repo the workflow triggered is based
on that prefix in the release tag. For example, by creating a release with the tag `ts18.4.1-alpha`
the release workflow for the `toolshed` container will be triggered.

### opencyphal/toolshed:ts

The [Open Cyphal toolshed
container](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed)
is based on Ubuntu and provides the necessary compilers and utilities to build and run OpenCyphal C or C++ projects
like [libcanard](https://github.com/OpenCyphal/libcanard) and
[Nunavut](https://github.com/OpenCyphal/nunavut).

#### Supported Versions

| tag      | Python | GCC (native) | GCC (arm-none-eabi) | Clang (native) | Cmake | Host Platforms | Other Utilities |
|----------|--------|--------------|---------------------|----------------|-------|----------------|-----------------|
| [ts24.4.3](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | <ul><li>3.12</li><li>3.10</li></ul> | <ul><li>13.3.0</li><li>12.3.0</li><li>11.4.0</li><li>10.5.0</li><li>7.5.0</li></ul>| 13.3.1 | <ul><li>19.1.7</li><li>18.1.8</li></ul> | 3.31.5 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <ul><li>JLink V816</li><li>cppcheck-2.13</li><li>yakut 0.13.0</li><li>libpcap0.8-dev</li><li>network-tools</li><li>can-utils</li><li>doxygen 1.13.2</li><li>tox</li><li>nox</li><li>govr</li><li>gcc-multilib (amd64 only)</li></ul> |
| [ts24.4.2](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | <ul><li>3.12</li><li>3.10</li></ul> | <ul><li>13.3.0</li><li>12.3.0</li><li>11.4.0</li><li>10.5.0</li><li>7.5.0</li></ul>| 13.3.1 | <ul><li>19.1.7</li><li>18.1.8</li></ul> | 3.31.5 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <ul><li>yakut 0.13.0</li><li>libpcap0.8-dev</li><li>network-tools</li><li>can-utils</li><li>doxygen 1.13.2</li><li>gcc-multilib (amd64 only)</li></ul> |
| [ts24.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | <ul><li>3.12</li><li>3.10</li></ul> | <ul><li>13.3.0</li><li>12.3.0</li><li>11.4.0</li><li>10.5.0</li><li>7.5.0</li></ul>| 13.3.1 | <ul><li>19.1.7</li><li>18.1.8</li></ul> | 3.31.5 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <li>can-utils</li><li>doxygen 1.13.2</li><li>tox</li><li>nox</li><li>govr</li><li>gcc-multilib (amd64 only)</li></ul> |
| [ts22.4.10](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | 3.10 | 12.3.0 | 13.3.1 | 18.1.3 | 3.30.1 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <ul><li>qemu</li><li>can-utils</li><li>doxygen 1.10.0</li><li>nvm</li><li>node 20.x</li><li>nox</li><li>govr</li><li>gcc-multilib (amd64 only)</li></ul> |
| [ts22.4.8](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | 3.10 | 12.3.0 | (N/A) | 18.1.3 | 3.22.1 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <ul><li>qemu</li><li>can-utils</li><li>doxygen 1.10.0</li><li>nvm</li><li>node 20.x</li><li>nox</li><li>govr</li><li>gcc-multilib (amd64 only)</li></ul> |
| [ts22.4.7](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | 3.10 | 12.3.0 | (N/A) | 18.1.3 | 3.22.1 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | <ul><li>qemu</li><li>can-utils</li><li>doxygen 1.10.0</li><li>nvm</li><li>node 20.x</li><li>nox</li><li>govr</li></ul> |


You can use this in your workflow yaml like this:

```none
jobs:
  my-job:
    runs-on: ubuntu-latest
    container: ghcr.io/opencyphal/toolshed:ts22.4.7
```


### opencyphal/texer:te

The [Open Cyphal texer
container](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/texer)
is based on Ubuntu and provides the necessary compilers and utilities to author and publish OpenCyphal [LaTeX](https://www.latex-project.org/) documents like [the specification](https://github.com/OpenCyphal/specification).

#### Supported Versions

| tag      | Python | Tex Live | git | Platforms | Other Utilities |
|----------|--------|----------|-----|-----------|-----------------|
| [te22.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/texer) | 3.11 | 2022 | 2.34.1 | <ul><li>linux/amd64</li></ul> | <ul><li>python pygments</li><li>lyx</li><li>inkscape</li></ul> |
| [te20.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/texer) | 3.11 | 2019 | 2.25.1 | <ul><li>linux/amd64</li></ul> | <ul><li>python pygments</li><li>lyx</li><li>inkscape</li></ul> |

You can use this in your workflow yaml like this:

```none
jobs:
  my-job:
    runs-on: ubuntu-latest
    container: ghcr.io/opencyphal/texer:te20.4.1
```



 ### opencyphal/toxic:tx


The [Open Cyphal toxic
container](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic)
is based on Ubuntu and provides all modern Python3 distributions, pip, tox, and nox. It can be used to develop, test, build, and release Python projects like [nunavut](https://github.com/OpenCyphal/nunavut), [pydsdl](https://github.com/OpenCyphal/pydsdl), and [pycyphal](https://github.com/OpenCyphal/pycyphal).

#### Supported Versions

| tag      | Base Python | Python Versions | Tox | Nox | pip | Platforms | Other Utilities |
|----------|-------------|-----------------|-----|-----|-----|-----------|-----------------|
| [tx22.4.3](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic) | 3.11 | 3.8, 3.9, 3.10, 3.11, 3.12 3.13 | 4.13.0 | 2023.4.22 | 20.0.2 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | |
| [tx22.4.2](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic) | 3.10 | 3.7, 3.8, 3.9, 3.10, 3.11, 3.12 | 4.13.0 | 2023.4.22 | 20.0.2 | <ul><li>linux/amd64</li><li>linux/arm64</li></ul> | |
| [tx22.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic) | 3.8 | 3.7, 3.8, 3.9, 3.10, 3.11, 3.12 | 4.4.5 | 2023.4.22 | 20.0.2 | <ul><li>linux/amd64</li></ul> | |
| [tx20.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic) | 3.8 | 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12 | 4.4.5 | (not available) | 20.0.2 | <ul><li>linux/amd64</li></ul> | <ul><li>sonar-scanner</li></ul> |


You can use this in your workflow yaml like this:

```none
jobs:
  my-job:
    runs-on: ubuntu-latest
    container: ghcr.io/opencyphal/toxic:tx20.4.2
```

---------------------------

Note that, if you create a new container in this project, the prefix cannot end with 'v'. So "tu22.4.1" is okay but
"tv28.3.1" won't work because the release workflows elide "v" (as in version) by default and the container will become
"t28.3.1" in packages but "tv.28.3.1" as a git tag.
