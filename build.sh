#!/bin/bash

set -eEuo pipefail

declare -r VERSION_TESTINFRA=$1

declare -r IMAGE_TAG_BASE="renatomefi/docker-testinfra"
declare -r IMAGE_TAG="${IMAGE_TAG_BASE}:${VERSION_TESTINFRA}"

sed -E "s/pip install testinfra/pip install testinfra==${VERSION_TESTINFRA}/g" Dockerfile | \
    docker build --pull -t "${IMAGE_TAG}" -f - .

for TAG_EXTRA in "$@"
do
    docker tag "${IMAGE_TAG}" "${IMAGE_TAG_BASE}:${TAG_EXTRA}" \
    && echo "${IMAGE_TAG_BASE}:${TAG_EXTRA}" >> ./tmp/tags.list
done
