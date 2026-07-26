#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

MLIR_VERSION=${1}
MLIR_ALTERNATIVES_PRI=${2}
MLIR_ALTERNATIVES_PATH="/usr/bin/"

setup_mlir_alternatives()
{
    local version=${1}
    local priority=${2}
    local group=${3}
    local members=${4}
    local path=${5}
    local cmdln
    local member

    cmdln="--verbose --install ${path}${group} ${group} ${path}${group}-${version} ${priority}"
    for member in ${members}; do
        if [[ -x "${path}${member}-${version}" ]]; then
            cmdln="${cmdln} --slave ${path}${member} ${member} ${path}${member}-${version}"
        fi
    done
    update-alternatives ${cmdln}
}

MLIR_ALTERNATIVES_GROUP=""
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-linalg-ods-yaml-gen"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-lsp-server"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-minimal-opt"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-minimal-opt-canonicalize"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-pdll"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-pdll-lsp-server"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-query"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-reduce"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-rewrite"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-runner"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-tblgen"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-transform-opt"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} mlir-translate"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} tblgen-lsp-server"
MLIR_ALTERNATIVES_GROUP="${MLIR_ALTERNATIVES_GROUP} tblgen-to-irdl"

setup_mlir_alternatives "${MLIR_VERSION}" "${MLIR_ALTERNATIVES_PRI}" "mlir-opt" "${MLIR_ALTERNATIVES_GROUP}" "${MLIR_ALTERNATIVES_PATH}"
