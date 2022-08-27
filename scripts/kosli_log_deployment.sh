#!/usr/bin/env bash
set -Eeu

export KOSLI_OWNER=cyber-dojo
export KOSLI_API_TOKEN=${MERKELY_API_TOKEN}
export KOSLI_PIPELINE=differ
export KOSLI_ENVIRONMENT="${1}"
export KOSLI_HOST="${2}"

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${MY_DIR}/kosli.sh"

docker pull $(image_name)
install_kosli
kosli pipeline deployment report $(image_name) \
  --artifact-type docker

