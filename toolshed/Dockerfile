#
# Builds the toolshed/ubuntu-22.04 toolchain container.
#
FROM ubuntu:22.04 AS base

LABEL org.opencontainers.image.source=https://github.com/OpenCyphal/docker_toolchains
LABEL org.opencontainers.image.description="Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal C and C++ based projects."
LABEL org.opencontainers.image.licenses=MIT

ARG TARGETARCH

VOLUME /repo

WORKDIR /repo

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


# +---------------------------------------------------------------------------+
# | UBUNTU PROVISIONING
# +---------------------------------------------------------------------------+
FROM base AS provisioning
WORKDIR /tmp
ADD pre-provision.sh ./pre-provision.sh
ADD provision.sh ./provision.sh
ADD provision-${TARGETARCH}.sh ./provision-${TARGETARCH}.sh
ADD post-provision.sh ./post-provision.sh

RUN ./pre-provision.sh
RUN ./provision.sh
RUN ./provision-${TARGETARCH}.sh
RUN ./post-provision.sh

# INSTALL THE PATH FOR INTERATIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | NVM/nodejs
# +---------------------------------------------------------------------------+
FROM provisioning AS node

WORKDIR /tmp
ADD nvm-install.sh ./nvm-install.sh
RUN cat ./nvm-install.sh | bash
ENV NVM_DIR="~/.nvm"
RUN . ~/.nvm/nvm.sh && nvm install v20

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | INSTALL PYTHON STUFF
# +---------------------------------------------------------------------------+
FROM node AS python
WORKDIR /tmp

RUN pip3 install virtualenv
RUN pip3 install tox
RUN pip3 install nox
RUN pip3 install gcovr
RUN pip3 list

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | LLVM
# +---------------------------------------------------------------------------+
FROM python AS llvm
WORKDIR /tmp

ADD llvm-install.sh ./llvm-install.sh
ADD llvm-select.sh ./llvm-select.sh
RUN ./llvm-install.sh 18 all
RUN ./llvm-select.sh 18

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | DOXYGEN BUILD (PARALLEL)
# +---------------------------------------------------------------------------+
FROM llvm AS doxygen
WORKDIR /tmp
RUN mkdir doxygen-Release
RUN mkdir doxygen-Release/build
COPY cached-download.sh .

ARG DOXYGEN_VERSION=1_10_0

COPY doxygen-Release_${DOXYGEN_VERSION}.sha512.txt .
RUN --mount=type=cache,target=/doxygen-download \
    ./cached-download.sh \
    --cache-target "/doxygen-download" \
    --download-url "https://github.com/doxygen/doxygen/archive/refs/tags/Release_${DOXYGEN_VERSION}.tar.gz" \
    --download-to-file "/doxygen-download/doxygen-Release_${DOXYGEN_VERSION}.tar.gz" \
    --checksums "/tmp/doxygen-Release_${DOXYGEN_VERSION}.sha512.txt" \
    --tar-args "--strip-components=1" \
    --unpack-dir "/tmp/doxygen-Release"


WORKDIR /tmp/doxygen-Release/build
RUN cmake -G "Ninja"  -Dbuild_parse:BOOL=ON ..
RUN cmake --build .
RUN cmake --install .

WORKDIR /tmp
RUN rm -rf doxygen-Release

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | GCC::native
# +---------------------------------------------------------------------------+
FROM doxygen AS gcc-select

WORKDIR /tmp

ADD gcc-select.sh ./gcc-select.sh
RUN ./gcc-select.sh 12
RUN update-alternatives --display gcc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

