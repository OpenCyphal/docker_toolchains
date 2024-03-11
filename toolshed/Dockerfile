#
# Builds the toolshed/ubuntu-22.04 toolchain container.
#
FROM ubuntu:22.04 AS base

LABEL org.opencontainers.image.source=https://github.com/OpenCyphal/docker_toolchains
LABEL org.opencontainers.image.description="Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal C and C++ based projects."
LABEL org.opencontainers.image.licenses=MIT

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
ADD post-provision.sh ./post-provision.sh

RUN ./pre-provision.sh
RUN ./provision.sh
RUN ./post-provision.sh


# +---------------------------------------------------------------------------+
# | NVM/nodejs
# +---------------------------------------------------------------------------+
FROM provisioning AS node

WORKDIR /tmp
ADD nvm-install.sh ./nvm-install.sh
RUN cat ./nvm-install.sh | bash
ENV NVM_DIR="~/.nvm"
RUN . ~/.nvm/nvm.sh && nvm install v20


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


# +---------------------------------------------------------------------------+
# | LLVM
# +---------------------------------------------------------------------------+
FROM python AS llvm
WORKDIR /tmp

ADD llvm-install.sh ./llvm-install.sh
ADD llvm-select.sh ./llvm-select.sh
RUN ./llvm-install.sh 18 all
RUN ./llvm-select.sh 18


# +---------------------------------------------------------------------------+
# | GCC
# +---------------------------------------------------------------------------+
FROM llvm AS gcc-arm64

ARG GCC_HOST_PLATFORM=aarch64

FROM llvm AS gcc-amd64

ARG GCC_HOST_PLATFORM=x86_64

FROM gcc-$TARGETARCH AS gcc
WORKDIR /tmp
COPY cached-download.sh .

# ARM: M-Cores, Bare Metal
ARG GCC_ARM_NONE_EABI_PLATFORM=${GCC_HOST_PLATFORM}
ARG GCC_ARM_NONE_EABI_VERSION=11.2-2022.02
ARG GCC_ARM_NONE_EABI_TRIPLE=arm-none-eabi
ARG GCC_ARM_NONE_EABI_BASENAME=gcc-arm-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}-${GCC_ARM_NONE_EABI_TRIPLE}
ARG GCC_ARM_NONE_EABI_REV=99a2bce6f4464be08eca01eda13e4e96
ARG GCC_ARM_NONE_EABI_HASH=C371F8D384D7F8DC08BFE154352AA3AE

WORKDIR /tmp
COPY ${GCC_ARM_NONE_EABI_BASENAME}.sha512.txt .
RUN --mount=type=cache,target=/gcc-download \
    ./cached-download.sh \
    --cache-target "/gcc-download" \
    --download-url "https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_EABI_VERSION}/binrel/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_EABI_REV}&hash=${GCC_ARM_NONE_EABI_HASH}" \
    --download-to-file "/gcc-download/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz" \
    --checksums "/tmp/${GCC_ARM_NONE_EABI_BASENAME}.sha512.txt" \
    --unpack-dir "/usr/share/"

ENV PATH="/usr/share/${GCC_ARM_NONE_EABI_BASENAME}/bin:${PATH}"

RUN ${GCC_ARM_NONE_EABI_TRIPLE}-gcc --version

# ARM: A-Cores, Linux
ARG GCC_ARM_NONE_LINUX_PLATFORM=${GCC_HOST_PLATFORM}
ARG GCC_ARM_NONE_LINUX_VERSION=11.2-2022.02
ARG GCC_ARM_NONE_LINUX_TRIPLE=arm-none-linux-gnueabihf
ARG GCC_ARM_NONE_LINUX_BASENAME=gcc-arm-${GCC_ARM_NONE_LINUX_VERSION}-${GCC_ARM_NONE_LINUX_PLATFORM}-${GCC_ARM_NONE_LINUX_TRIPLE}
ARG GCC_ARM_NONE_LINUX_REV=ffc49e4af4cb4c298c2110a4d887716c
ARG GCC_ARM_NONE_LINUX_HASH=13DC7A96AEA6FB1D479EB23B782E79EB

COPY ${GCC_ARM_NONE_LINUX_BASENAME}.sha512.txt .
RUN --mount=type=cache,target=/gcc-download \
    ./cached-download.sh \
    --cache-target "/gcc-download" \
    --download-url "https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_LINUX_VERSION}/binrel/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_LINUX_REV}&hash=${GCC_ARM_NONE_LINUX_HASH}" \
    --download-to-file "/gcc-download/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz" \
    --checksums "/tmp/${GCC_ARM_NONE_LINUX_BASENAME}.sha512.txt" \
    --unpack-dir "/usr/share/"

ENV PATH="/usr/share/${GCC_ARM_NONE_LINUX_BASENAME}/bin:${PATH}"

RUN ${GCC_ARM_NONE_LINUX_TRIPLE}-gcc --version


# +---------------------------------------------------------------------------+
# | DOXYGEN BUILD (PARALLEL)
# +---------------------------------------------------------------------------+
FROM provisioning AS doxygen
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


# +---------------------------------------------------------------------------+
# | FINALIZE
# +---------------------------------------------------------------------------+
FROM gcc AS all

# Install the doxygen build we did in parallel
COPY --from=doxygen /tmp/doxygen-Release/build /tmp/doxygen-Release/build
WORKDIR /tmp/doxygen-Release/build
RUN cmake --install .

WORKDIR /tmp
RUN rm -rf doxygen-Release

# INSTALL THE PATH FOR INTERATIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo
