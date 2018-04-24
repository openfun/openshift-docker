#!/usr/bin/env bash

set -eo pipefail

# Enable aliases definition even if we are not running an interactive shell
shopt -s expand_aliases

declare DOCKERHUB_NAMESPACE="fundocker"
declare IMAGE_NAME_PREFIX="openshift-"
declare BASE_SERVICE_IMAGE_PATH="docker/images"


function _check_service_argument() {
    if [[ -z $2 ]]; then
        echo "$1: service name is missing"
        exit 1
    fi
}

# Avoid repetition by declaring an alias
alias _check_service_argument='_check_service_argument ${FUNCNAME} $*'

# Get the Dockerfile path of a service
#
# Usage: _get_service_image_path SERVICE
function _get_service_image_path() {
    _check_service_argument

    local service=$1

    echo "${BASE_SERVICE_IMAGE_PATH}/${service}/Dockerfile"
}


# Check that the Dockerfile path of a service actually exists
#
# Usage: _check_service_image_path SERVICE
function _check_service_image_path() {
    _check_service_argument

    local service=$1
    local service_image_path=$(_get_service_image_path $service)

    if [[ ! -e $service_image_path ]]; then
        echo "Service image path does not exists: $service_image_path"
        exit 1
    fi
}


# Get base image tag (as extracted from the service's Dockerfile tag)
#
# Usage: _get_base_image_tag SERVICE
function _get_base_image_tag() {
    _check_service_argument

    local service=$1
    local dockerfile=$(_get_service_image_path $service)

    echo $(grep FROM ${dockerfile} | head -n 1 | sed 's/^.*FROM \(.*\):\(.*\)/\2/')
}


# Get target image tag (fully qualified, e.g. namespace/name:tag)
#
# Usage: _get_target_image_fullname SERVICE
function _get_target_image_fullname() {
    _check_service_argument

    local service=$1
    local tag=$(_get_base_image_tag $service)

    echo "${DOCKERHUB_NAMESPACE}/${IMAGE_NAME_PREFIX}${service}:${tag}"
}


# Check if target image has been built and is available locally
#
# Usage: _check_target_image_exists SERVICE
function _check_target_image_exists() {
    _check_service_argument

    local service=$1
    local image=$(_get_target_image_fullname $service)

    if ! docker images $tag | grep $service &> /dev/null; then
        echo "Target image '${image}' does not exists! You should build it first (see: bin/build)"
        exit 1
    fi
}
