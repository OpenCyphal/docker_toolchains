#
# Builds the toolshed/ubuntu-22.04 toolchain container.
#
FROM ubuntu:22.04 AS base

LABEL org.opencontainers.image.description "Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal C and C++ based projects."

VOLUME /repo

WORKDIR /repo

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# +---------------------------------------------------------------------------+
# | BASE INSTALL
# +---------------------------------------------------------------------------+
COPY provision.sh /
RUN /provision.sh


# +---------------------------------------------------------------------------+
# | NVM/nodejs
# +---------------------------------------------------------------------------+
FROM base AS node

WORKDIR /tmp
ADD nvm-install.sh ./nvm-install.sh
RUN . ./nvm-install.sh
ENV NVM_DIR="~/.nvm"
RUN . ~/.nvm/nvm.sh && nvm install v16.20.0


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

# ARM: M-Cores, Bare Metal
ARG GCC_ARM_NONE_EABI_PLATFORM=${GCC_HOST_PLATFORM}
ARG GCC_ARM_NONE_EABI_VERSION=11.2-2022.02
ARG GCC_ARM_NONE_EABI_TRIPLE=arm-none-eabi
ARG GCC_ARM_NONE_EABI_BASENAME=gcc-arm-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}-${GCC_ARM_NONE_EABI_TRIPLE}
ARG GCC_ARM_NONE_EABI_REV=99a2bce6f4464be08eca01eda13e4e96
ARG GCC_ARM_NONE_EABI_HASH=C371F8D384D7F8DC08BFE154352AA3AE

WORKDIR /tmp
COPY ${GCC_ARM_NONE_EABI_BASENAME}.sha512.txt .
ADD https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_EABI_VERSION}/binrel/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_EABI_REV}&hash=${GCC_ARM_NONE_EABI_HASH} /tmp/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz
RUN sha512sum -c ${GCC_ARM_NONE_EABI_BASENAME}.sha512.txt
RUN tar xJf ${GCC_ARM_NONE_EABI_BASENAME}.tar.xz -C /usr/share/
RUN rm ${GCC_ARM_NONE_EABI_BASENAME}.tar.xz

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
ADD https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_LINUX_VERSION}/binrel/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_LINUX_REV}&hash=${GCC_ARM_NONE_LINUX_HASH} /tmp/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz
RUN sha512sum -c ${GCC_ARM_NONE_LINUX_BASENAME}.sha512.txt
RUN tar xJf ${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz -C /usr/share/
RUN rm ${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz

ENV PATH="/usr/share/${GCC_ARM_NONE_LINUX_BASENAME}/bin:${PATH}"

RUN ${GCC_ARM_NONE_LINUX_TRIPLE}-gcc --version


# +---------------------------------------------------------------------------+
# | DOXYGEN BUILD
# +---------------------------------------------------------------------------+
FROM gcc AS doxygen-arm64

ARG USE_LIB_CLANG=OFF

FROM gcc AS doxygen-amd64

ARG USE_LIB_CLANG=OFF

FROM doxygen-$TARGETARCH AS doxygen
WORKDIR /tmp

ARG DOXYGEN_VERSION=1_9_6

COPY doxygen-Release_${DOXYGEN_VERSION}.sha512.txt .
ADD https://github.com/doxygen/doxygen/archive/refs/tags/Release_${DOXYGEN_VERSION}.tar.gz doxygen-Release_${DOXYGEN_VERSION}.tar.gz
RUN sha512sum -c doxygen-Release_${DOXYGEN_VERSION}.sha512.txt
RUN mkdir doxygen-Release
RUN tar -xvf doxygen-Release_${DOXYGEN_VERSION}.tar.gz -C doxygen-Release --strip-components 1
RUN rm doxygen-Release_${DOXYGEN_VERSION}.tar.gz
RUN mkdir doxygen-Release/build

WORKDIR /tmp/doxygen-Release/build
RUN cmake -G "Unix Makefiles"  -Dbuild_parse:BOOL=ON -Duse_libclang:BOOL=${USE_LIB_CLANG} ..
RUN make
RUN make install

WORKDIR /tmp
RUN rm -rf doxygen-Release


# +---------------------------------------------------------------------------+
# | FINALIZE
# +---------------------------------------------------------------------------+
FROM doxygen AS all

# INSTALL THE PATH FOR INTERATIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo
