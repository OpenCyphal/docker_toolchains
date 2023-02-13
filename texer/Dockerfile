#
# Builds the toolshed/ubuntu-20.04 toolchain container.
#
FROM ubuntu:20.04

LABEL org.opencontainers.image.description "Provides a consistent build and test environment for authoring, continuous-integration, and publication of OpenCyphal LaTeX documents."

VOLUME /repo

WORKDIR /repo


ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update

# setup locales in the container so Python can default to utf-8.
RUN apt-get -y install apt-utils
RUN apt-get -y install locales

# from http://jaredmarkell.com/docker-and-locales/
RUN locale-gen en_US.UTF-8

RUN apt-get -y install software-properties-common
RUN apt-get -y install texlive-full
RUN apt-get -y install lyx
RUN apt-get -y install inkscape
RUN apt-get -y install git

RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update

RUN apt-get -y install python3.11
RUN apt-get -y install python3.11-distutils
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 999

COPY get-pip.py /
RUN python3 /get-pip.py
RUN rm -f /get-pip.py

RUN python3 -m pip install pygments

# install Powershell
RUN apt-get -y install --no-install-recommends wget apt-transport-https
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb
RUN apt-get update && \
  apt-get install -y powershell
