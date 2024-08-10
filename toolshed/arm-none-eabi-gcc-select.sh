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

    cmdln="--verbose --install /usr/bin/${group} ${group} ${path}${group}-${version} ${priority}"
    for member in ${members}; do
        cmdln="${cmdln} --slave ${path}${member} ${member} ${path}${member}-${version}"
    done
    update-alternatives ${cmdln}
}

GCC_ALTERNATIVES_PRI=${2}
GCC_ALTERNATIVES_PATH=${3}

# setup gcc group
GCC_ALTERNATIVES_GROUP_GCC_CONFIG=""
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-g++"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcc-ar"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcc-nm"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcc-ranlib"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcov"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcov-dump"
GCC_ALTERNATIVES_GROUP_GCC_CONFIG="${GCC_ALTERNATIVES_GROUP_GCC_CONFIG} arm-none-eabi-gcov-tool"

setup_gcc_alternatives "${GCC_VERSION}" "${GCC_ALTERNATIVES_PRI}" "arm-none-eabi-gcc" "${GCC_ALTERNATIVES_GROUP_GCC_CONFIG}" "${GCC_ALTERNATIVES_PATH}"
