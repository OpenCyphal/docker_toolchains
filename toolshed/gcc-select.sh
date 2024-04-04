#!/bin/bash


GCC_VERSION=${1}

setup_gcc_alternatives()
{
    local version=${1}
    local priority=${2}
    local group=${3}
    local members=${4}
    local path=${5}
    local cmdln

    cmdln="--verbose --install ${path}${group} ${group} ${path}${group}-${version} ${priority}"
    for member in ${members}; do
        cmdln="${cmdln} --slave ${path}${member} ${member} ${path}${member}-${version}"
    done
    update-alternatives ${cmdln}
}

GCC_ALTERNATIVES_PRI=99
GCC_ALTERNATIVES_PATH="/usr/bin/"

# setup llvm-config group
GCC_ALTERNATIVES_GROUP_GCC_CONFIG=""
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} g++"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} gcc-ar"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} gcc-nm"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} gcc-ranlib"

setup_gcc_alternatives "${GCC_VERSION}" "${GCC_ALTERNATIVES_PRI}" "gcc" "${GCC_ALTERNATIVES_GROUP_GCC_CONFIG}" "${GCC_ALTERNATIVES_PATH}"
