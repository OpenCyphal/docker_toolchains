#
# Builds a docker image with Python and Node.js to use for tox runs.
#
FROM ubuntu:18.04

VOLUME /repo

WORKDIR /repo


ENV SONAR_SCANNER_VERSION 4.2.0.1873
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV SONAR_SCANNER_HOME=/sonar-scanner-${SONAR_SCANNER_VERSION}-linux
ENV SONAR_SCANNER_OPTS="-server"

ENV PATH="${SONAR_SCANNER_HOME}/sonar-scanner-${SONAR_SCANNER_VERSION}-linux/bin:${PATH}"

COPY provision.sh /

RUN /provision.sh
