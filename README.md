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

| tag      | Python | Gcc | Clang | Cmake | Other Utilities |
|----------|--------|-----|-------|-------|-----------------|
| [ts20.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toolshed) | 3.10 | 9.3.0 | 10.0.0 | 3.16.3 | <ul><li>qemu</li><li>can-utils</li><li>sonar-scanner</li></ul> |

You can use this in your workflow yaml like this:

```none
jobs:
  my-job:
    runs-on: ubuntu-latest
    container: ghcr.io/opencyphal/toolshed:ts20.4.1
```


### opencyphal/texer:te

The [Open Cyphal texer
container](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/texer)
is based on Ubuntu and provides the necessary compilers and utilities to author and publish OpenCyphal [LaTeX](https://www.latex-project.org/) documents like [the specification](https://github.com/OpenCyphal/specification).

#### Supported Versions

| tag      | Python | Tex Live | git | Other Utilities |
|----------|--------|----------|-----|-----------------|
| [te20.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/texer) | 3.11 | 2019 | 2.25.1 | <ul><li>python pygments</li><li>lyx</li><li>inkscape</li></ul> |

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

| tag      | Base Python | Python Versions | Tox | Nox | pip | Other Utilities |
|----------|-------------|-----------------|-----|-----|-----|-----------------|
| [tx20.4.1](https://github.com/OpenCyphal/docker_toolchains/pkgs/container/toxic) | 3.8 | 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12 | 4.4.5 | (not available) | 20.0.2 | <ul><li>sonar-scanner</li></ul> |

You can use this in your workflow yaml like this:

```none
jobs:
  my-job:
    runs-on: ubuntu-latest
    container: ghcr.io/opencyphal/toxic:tx20.4.1
```

---------------------------

Note that, if you create a new container in this project, the prefix cannot end with 'v'. So "tu22.4.1" is okay but
"tv28.3.1" won't work because the release workflows elide "v" (as in version) by default and the container will become
"t28.3.1" in packages but "tv.28.3.1" as a git tag.