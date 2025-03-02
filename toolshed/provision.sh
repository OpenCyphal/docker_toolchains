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

apt-get -y install apt-utils
apt-get -y install moreutils
apt-get -y install python3.10
apt-get -y install python3-pip
apt-get -y install python3-virtualenv
apt-get -y install cmake
apt-get -y install git
apt-get -y install flex
apt-get -y install bison
apt-get -y install lcov
apt-get -y install valgrind
apt-get -y install graphviz
apt-get -y install curl
apt-get -y install ninja-build
apt-get -y install can-utils
apt-get -y install lsb-release
apt-get -y install wget
apt-get -y install gnupg
apt-get -y install vim
apt-get -y install g++-7
apt-get -y install g++-10
apt-get -y install g++-11
apt-get -y install g++-12
apt-get -y install g++-13
apt-get -y install nodejs
apt-get -y install npm
apt-get -y install libpcap0.8-dev
apt-get -y install net-tools
apt-get -y install iproute2
apt-get -y install cppcheck
apt-get -y install libncurses5
