#
# Builds the c_cpp/ubuntu-18.04 toolchain container.
#
FROM ubuntu:18.04

VOLUME /repo

WORKDIR /tmp


ENV SONAR_SCANNER_VERSION 4.2.0.1873
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV SONAR_SCANNER_HOME=/sonar-scanner-${SONAR_SCANNER_VERSION}-linux
ENV SONAR_SCANNER_OPTS="-server"

ENV PATH="${SONAR_SCANNER_HOME}/build-wrapper-linux-x86:${PATH}"
ENV PATH="${SONAR_SCANNER_HOME}/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:${PATH}"

COPY provision.sh /
COPY sonar_qube.sh /

RUN /provision.sh
RUN /sonar_qube.sh
RUN pip3 install virtualenv
RUN pip3 install tox
RUN npm install -g gh-pages
