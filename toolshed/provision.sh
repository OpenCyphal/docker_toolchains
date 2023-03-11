#!/usr/bin/env bash

# +----------------------------------------------------------+
# | BASH : Modifying Shell Behaviour
# |    (https://www.gnu.org/software/bash/manual)
# +----------------------------------------------------------+
# Treat unset variables and parameters other than the special
# parameters ‘@’ or ‘*’ as an error when performing parameter
# expansion. An error message will be written to the standard
# error, and a non-interactive shell will exit.
set -o nounset

# Exit immediately if a pipeline returns a non-zero status.
set -o errexit

# If set, the return value of a pipeline is the value of the
# last (rightmost) command to exit with a non-zero status, or
# zero if all commands in the pipeline exit successfully.
set -o pipefail

# +----------------------------------------------------------+
export DEBIAN_FRONTEND=noninteractive

apt-get update

# setup locales in the container so Python can default to utf-8.
apt-get -y install locales
# from http://jaredmarkell.com/docker-and-locales/
locale-gen en_US.UTF-8
export ENV LANG=en_US.UTF-8
export ENV LANGUAGE=en_US:en
export ENV LC_ALL=en_US.UTF-8

apt-get -y install software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get -y install apt-utils
apt-get -y install python3.10
apt-get -y install python3-pip
apt-get -y install cmake
apt-get -y install git
apt-get -y install llvm
apt-get -y install clang
apt-get -y install libclang-dev
apt-get -y install clang-format
apt-get -y install clang-tidy
apt-get -y install flex
apt-get -y install bison
apt-get -y install lcov
apt-get -y install valgrind
apt-get -y install npm
apt-get -y install graphviz
apt-get -y install curl
apt-get -y install unzip
apt-get -y install zip
apt-get -y install gcc-multilib
apt-get -y install g++-multilib
apt-get -y install qemu
apt-get -y install ninja-build
apt-get -y install can-utils
apt-get -y install vim

echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=en_US:en" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "alias la=\"ls -lah\"" >> ~/.bashrc
