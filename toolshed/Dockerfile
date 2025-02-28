#
# Builds the toolshed/ubuntu-22.04 toolchain container.
#
FROM ubuntu:24.04 AS base

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
ADD kitware-archive-latest.asc .
ADD pre-provision.sh ./pre-provision.sh
ADD provision-repositories.sh ./provision-repositories.sh
ADD provision-repositories-${TARGETARCH}.sh ./provision-repositories-${TARGETARCH}.sh
ADD provision.sh ./provision.sh
ADD provision-${TARGETARCH}.sh ./provision-${TARGETARCH}.sh
ADD post-provision.sh ./post-provision.sh

RUN apt update
RUN ./pre-provision.sh
RUN ./provision-repositories.sh
RUN ./provision-repositories-${TARGETARCH}.sh
RUN apt update
RUN ./provision.sh
RUN ./provision-${TARGETARCH}.sh
RUN ./post-provision.sh

# INSTALL THE PATH FOR INTERACTIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

# +---------------------------------------------------------------------------+
# | INSTALL PYTHON STUFF
# +---------------------------------------------------------------------------+
FROM provisioning AS python
WORKDIR /tmp

RUN apt-get -y install pipx
RUN echo "export PATH=/root/.local/bin:$PATH" >> ~/.bashrc
RUN pipx install tox
RUN pipx install nox
RUN pipx install gcovr
RUN pipx install yakut
RUN git clone --depth 1 https://github.com/OpenCyphal/public_regulated_data_types.git ~/public_regulated_data_types

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
RUN ./llvm-select.sh 18 18
RUN ./llvm-install.sh 19 all
RUN ./llvm-select.sh 19 99

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

ARG DOXYGEN_VERSION=1_13_2

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
RUN ./gcc-select.sh 7 7
RUN ./gcc-select.sh 10 10
RUN ./gcc-select.sh 11 11
RUN ./gcc-select.sh 12 12
RUN ./gcc-select.sh 13 99
RUN update-alternatives --display gcc

# +---------------------------------------------------------------------------+
# | arm-none-eabi-gcc
# +---------------------------------------------------------------------------+
FROM gcc-select AS arm-none-eabi-arm64
ARG GCC_HOST_VERSION=aarch64

FROM gcc-select AS arm-none-eabi-amd64
ARG GCC_HOST_VERSION=x86_64

FROM arm-none-eabi-${TARGETARCH} AS arm-none-eabi
WORKDIR /tmp
COPY cached-download.sh .

ARG ARM_NONE_EABI_VERSION=13.3.rel1
ARG ARM_NONE_EABI_CHECKSUM_FILE=arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz.sha256asc

COPY ${ARM_NONE_EABI_CHECKSUM_FILE} .
RUN --mount=type=cache,target=/arm-none-eabi-download \
    ./cached-download.sh \
    --cache-target "/arm-none-eabi-download" \
    --download-url "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_NONE_EABI_VERSION}/binrel/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz" \
    --download-to-file "/arm-none-eabi-download/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz" \
    --checksums "/tmp/${ARM_NONE_EABI_CHECKSUM_FILE}" \
    --algorithm 256 \
    --unpack-dir "/opt"

ADD arm-none-eabi-gcc-select.sh ./arm-none-eabi-gcc-select.sh
RUN ./arm-none-eabi-gcc-select.sh 1 /opt/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi/bin/
RUN update-alternatives --display arm-none-eabi-gcc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo
