#!/bin/bash

set -eEuo pipefail

declare -r VERSION_PYTHON=$1
declare -r VERSION_TESTINFRA=$2
declare VERSION_PYTHON_NUMERIC
VERSION_PYTHON_NUMERIC=$(echo "${VERSION_PYTHON}" | tr -dc '0-9')

declare -r IMAGE_TAG_BASE="renatomefi/docker-testinfra"
declare -r IMAGE_TAG="${IMAGE_TAG_BASE}:${VERSION_TESTINFRA}-${VERSION_PYTHON}"

sed -E "/pip./ s/ testinfra/ testinfra==${VERSION_TESTINFRA}/g" "Dockerfile-${VERSION_PYTHON}" | \
    docker build --pull -t "${IMAGE_TAG}" -f - .

## safety check
docker run --rm -t "${IMAGE_TAG}" --version | \
    grep -q "testinfra-${VERSION_TESTINFRA}"
docker run --rm -t --entrypoint="${VERSION_PYTHON}" "${IMAGE_TAG}" --version | \
    grep -q "Python ${VERSION_PYTHON_NUMERIC}"

for TAG_EXTRA in "${@:3}"
do
    docker tag "${IMAGE_TAG}" "${IMAGE_TAG_BASE}:${TAG_EXTRA}" \
    && echo "${IMAGE_TAG_BASE}:${TAG_EXTRA}" >> ./tmp/tags.list
done
