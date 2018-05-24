#!/usr/bin/env bash

set -eo pipefail

# Enable aliases definition even if we are not running an interactive shell
shopt -s expand_aliases

declare DOCKERHUB_NAMESPACE="fundocker"
declare IMAGE_NAME_PREFIX="openshift-"
declare BASE_IMAGE_PATH="docker/images"


function _check_image_arguments() {
    if [[ -z $2 ]]; then
        echo "$1: image name is missing"
        exit 1
    fi

    if [[ -z $3 ]]; then
        echo "$1: image tag is missing"
        exit 1
    fi
}

# Avoid repetition by declaring an alias
alias _check_image_arguments='_check_image_arguments ${FUNCNAME} $*'

# Get the Dockerfile path of an image
#
# Usage: _get_image_path NAME TAG
function _get_image_path() {
    _check_image_arguments

    local name=$1
    local tag=$2

    echo "${BASE_IMAGE_PATH}/${name}/${tag}/Dockerfile"
}


# Check that the Dockerfile path of an image actually exists
#
# Usage: _check_image_path NAME TAG
function _check_image_path() {
    _check_image_arguments

    local name=$1
    local tag=$2
    local image_path=$(_get_image_path $name $tag)

    if [[ ! -e $image_path ]]; then
        echo "image path does not exist: $image_path"
        exit 1
    fi
}


# Get target image fullname (fully qualified, e.g. namespace/name:tag)
#
# Usage: _get_target_image_fullname NAME TAG
function _get_target_image_fullname() {
    _check_image_arguments

    local name=$1
    local tag=$2
 
    echo "${DOCKERHUB_NAMESPACE}/${IMAGE_NAME_PREFIX}${name}:${tag}"
}


# Check if target image has been built and is available locally
#
# Usage: _check_target_image_exists NAME TAG
function _check_target_image_exists() {
    _check_image_arguments

    local name=$1
    local tag=$2
    local image=$(_get_target_image_fullname $name $tag)

    if ! docker images $image | grep $name &> /dev/null; then
        echo "Target image '${image}' does not exist! You should build it first (see: bin/build)"
        exit 1
    fi
}
