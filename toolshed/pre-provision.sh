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
apt-get -y install unzip
apt-get -y install zip

# setup locales in the container so Python can default to utf-8.
apt-get -y install locales
# from http://jaredmarkell.com/docker-and-locales/
locale-gen en_US.UTF-8
# See Dockerfile for exports

apt-get -y install software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
