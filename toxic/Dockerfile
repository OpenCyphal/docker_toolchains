#
# Builds a docker image to use for development and CI.
#
FROM ubuntu:22.04

LABEL org.opencontainers.image.description "Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal Python based projects."

VOLUME /repo

WORKDIR /repo

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install apt-utils && apt-get -y install locales
RUN locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

COPY provision.sh /

RUN /provision.sh
