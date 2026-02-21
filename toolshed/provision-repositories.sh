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

apt-get -y install software-properties-common ca-certificates

KITWARE_KEYRING="/usr/share/keyrings/kitware-archive-keyring.gpg"
KITWARE_SOURCE_LIST="/etc/apt/sources.list.d/kitware.list"
KITWARE_KEY_ASC="/tmp/kitware-archive-latest.asc"

# Prefer the current upstream key in case the bundled key has expired.
if wget -qO "${KITWARE_KEY_ASC}" "https://apt.kitware.com/keys/kitware-archive-latest.asc"; then
    echo "Using Kitware key downloaded from apt.kitware.com"
else
    echo "Falling back to bundled Kitware key"
    cp kitware-archive-latest.asc "${KITWARE_KEY_ASC}"
fi

gpg --dearmor < "${KITWARE_KEY_ASC}" > "${KITWARE_KEYRING}"
chmod 0644 "${KITWARE_KEYRING}"
echo "deb [signed-by=${KITWARE_KEYRING}] https://apt.kitware.com/ubuntu/ jammy main" > "${KITWARE_SOURCE_LIST}"

add-apt-repository -y ppa:deadsnakes/ppa
