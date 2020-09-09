#
# Builds the c_cpp/ubuntu-18.04 toolchain container.
#
FROM ubuntu:18.04

VOLUME /repo

WORKDIR /repo


ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update

# setup locales in the container so Python can default to utf-8.
RUN apt-get -y install locales

# from http://jaredmarkell.com/docker-and-locales/
RUN locale-gen en_US.UTF-8

RUN apt-get -y install software-properties-common
RUN apt-get -y install apt-utils
RUN apt-get -y install texlive-full
RUN apt-get -y install lyx
RUN apt-get -y install git

RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update

RUN apt-get -y install python3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 999
RUN apt-get -y install python3-pip
RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install pygments

# install Powershell
RUN apt-get -y install --no-install-recommends wget apt-transport-https
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb
RUN apt-get update && \
  apt-get install -y powershell
