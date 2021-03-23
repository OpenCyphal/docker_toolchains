#
# Builds the c_cpp/ubuntu-20.04 toolchain container.
#
FROM ubuntu:20.04

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
ARG GCC_ARM_NONE_EABI_PLATFORM=x86_64-linux
ARG GCC_ARM_NONE_EABI_VERSION=10-2020-q4-major

WORKDIR /tmp
ADD https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2?revision=ca0cbf9c-9de2-491c-ac48-898b5bbc0443&la=en&hash=68760A8AE66026BCF99F05AC017A6A50C6FD832A /tmp/gcc-arm-none-eabi-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}.tar.bz2
RUN tar xjf gcc-arm-none-eabi-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}.tar.bz2 -C /usr/share/
RUN rm gcc-arm-none-eabi-${GCC_ARM_NONE_EABI_VERSION}-${GCC_ARM_NONE_EABI_PLATFORM}.tar.bz2

ENV PATH="/usr/share/gcc-arm-none-eabi-${GCC_ARM_NONE_EABI_VERSION}/bin:${PATH}"

HEALTHCHECK CMD arm-none-eabi-gcc --version

# +---------------------------------------------------------------------------+
# | INSTALL SONAR SCANNER
# +---------------------------------------------------------------------------+
ENV SONAR_SCANNER_VERSION 4.2.0.1873
ENV SONAR_SCANNER_HOME=/sonar-scanner-${SONAR_SCANNER_VERSION}-linux
ENV SONAR_SCANNER_OPTS="-server"

ENV PATH="${SONAR_SCANNER_HOME}/build-wrapper-linux-x86:${PATH}"
ENV PATH="${SONAR_SCANNER_HOME}/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:${PATH}"

COPY sonar_qube.sh /
RUN /sonar_qube.sh

# +---------------------------------------------------------------------------+
# | INSTALL PYTHON AND NPM STUFF
# +---------------------------------------------------------------------------+
RUN pip3 install virtualenv
RUN pip3 install tox
RUN cd /tmp && npm install -g gh-pages
