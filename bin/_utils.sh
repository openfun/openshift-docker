#!/usr/bin/env bash

set -eo pipefail

declare DOCKERHUB_NAMESPACE="fundocker"
declare IMAGE_NAME_PREFIX="openshift-"
declare BASE_SERVICE_IMAGE_PATH="docker/images"


# Get the Dockerfile path of a service
#
# Usage: _get_service_image_path SERVICE
function _get_service_image_path() {
    if [[ -z $1 ]]; then
        echo "get_service_image_path: service name is missing"
        exit 1
    fi

    local service=$1
    local service_image_path="${BASE_SERVICE_IMAGE_PATH}/${service}/Dockerfile"

    echo "$service_image_path"
}


# Check that the Dockerfile path of a service actually exists
#
# Usage: _check_service_image_path SERVICE
function _check_service_image_path() {
    if [[ -z $1 ]]; then
        echo "check_service_image_path: service name is missing"
        exit 1
    fi

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
    if [[ -z $1 ]]; then
        echo "get_base_image_tag: service name is missing"
        exit 1
    fi
    local service=$1
    local dockerfile=$(_get_service_image_path $service)

    echo $(grep FROM ${dockerfile} | head -n 1 | sed 's/^.*FROM \(.*\):\(.*\)/\2/')
}


# Get target image tag (fully qualified, e.g. namespace/name:tag)
#
# Usage: _get_target_image_tag SERVICE
function _get_target_image_tag() {
    if [[ -z $1 ]]; then
        echo "get_target_image_tag: service name is missing"
        exit 1
    fi
    local service=$1
    local version=$(_get_base_image_tag $service)

    echo "${DOCKERHUB_NAMESPACE}/${IMAGE_NAME_PREFIX}${service}:${version}"
}


# Check if target image has been built and is available locally
#
# Usage: _check_target_image_exists SERVICE
function _check_target_image_exists() {
    if [[ -z $1 ]]; then
        echo "check_target_image_exists: service name is missing"
        exit 1
    fi
    local service=$1
    local tag=$(_get_target_image_tag $service)

    if ! docker images $tag | grep $service &> /dev/null; then
        echo "Target image '${tag}' does not exists! You should build it first (see: bin/build)"
        exit 1
    fi
}
