#
# Builds the c_cpp/ubuntu-20.04 toolchain container.
#
FROM ubuntu:20.04

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
# | INSTALL TOOLCHAINS
# +---------------------------------------------------------------------------+

# ARM: M-Cores, Bare Metal
ARG GCC_ARM_NONE_EABI_PLATFORM=x86_64
ARG GCC_ARM_NONE_EABI_VERSION=11.2-2022.02
ARG GCC_ARM_NONE_EABI_TRIPLE=arm-none-eabi
ARG GCC_ARM_NONE_EABI_BASENAME=gcc-arm-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}-${GCC_ARM_NONE_EABI_TRIPLE}
ARG GCC_ARM_NONE_EABI_REV=99a2bce6f4464be08eca01eda13e4e96
ARG GCC_ARM_NONE_EABI_HASH=C371F8D384D7F8DC08BFE154352AA3AE

WORKDIR /tmp
ADD https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_EABI_VERSION}/binrel/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_EABI_REV}&hash=${GCC_ARM_NONE_EABI_HASH} /tmp/${GCC_ARM_NONE_EABI_BASENAME}.tar.xz
RUN tar xJf ${GCC_ARM_NONE_EABI_BASENAME}.tar.xz -C /usr/share/
RUN rm ${GCC_ARM_NONE_EABI_BASENAME}.tar.xz

ENV PATH="/usr/share/${GCC_ARM_NONE_EABI_BASENAME}/bin:${PATH}"

RUN ${GCC_ARM_NONE_EABI_TRIPLE}-gcc --version

# ARM: A-Cores, Linux
ARG GCC_ARM_NONE_LINUX_PLATFORM=x86_64
ARG GCC_ARM_NONE_LINUX_VERSION=11.2-2022.02
ARG GCC_ARM_NONE_LINUX_TRIPLE=arm-none-linux-gnueabihf
ARG GCC_ARM_NONE_LINUX_BASENAME=gcc-arm-${GCC_ARM_NONE_LINUX_VERSION}-${GCC_ARM_NONE_LINUX_PLATFORM}-${GCC_ARM_NONE_LINUX_TRIPLE}
ARG GCC_ARM_NONE_LINUX_REV=ffc49e4af4cb4c298c2110a4d887716c
ARG GCC_ARM_NONE_LINUX_HASH=13DC7A96AEA6FB1D479EB23B782E79EB

ADD https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_LINUX_VERSION}/binrel/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz?rev=${GCC_ARM_NONE_LINUX_REV}&hash=${GCC_ARM_NONE_LINUX_HASH} /tmp/${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz
RUN tar xJf ${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz -C /usr/share/
RUN rm ${GCC_ARM_NONE_LINUX_BASENAME}.tar.xz

ENV PATH="/usr/share/${GCC_ARM_NONE_LINUX_BASENAME}/bin:${PATH}"

RUN ${GCC_ARM_NONE_LINUX_TRIPLE}-gcc --version


# +---------------------------------------------------------------------------+
# | INSTALL SONAR SCANNER
# +---------------------------------------------------------------------------+
ENV SONAR_SCANNER_VERSION 4.7.0.2747
ENV SONAR_SCANNER_HOME=/sonar-scanner-${SONAR_SCANNER_VERSION}-linux
ENV SONAR_SCANNER_OPTS="-server"

ENV PATH="${SONAR_SCANNER_HOME}/build-wrapper-linux-x86:${PATH}"
ENV PATH="${SONAR_SCANNER_HOME}/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:${PATH}"

COPY sonar_qube.sh /
RUN /sonar_qube.sh

# +---------------------------------------------------------------------------+
# | INSTALL THE PATH FOR INTERATIVE SESSIONS
# +---------------------------------------------------------------------------+
RUN echo "export PATH=$PATH" >> ~/.bashrc

# +---------------------------------------------------------------------------+
# | INSTALL PYTHON AND NPM STUFF
# +---------------------------------------------------------------------------+
RUN pip3 install virtualenv
RUN pip3 install tox
RUN cd /tmp && npm install -g gh-pages
