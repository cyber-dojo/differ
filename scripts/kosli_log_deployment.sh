#!/bin/bash -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${MY_DIR}/kosli.sh"

export KOSLI_OWNER=cyber-dojo
export KOSLI_API_TOKEN=${MERKELY_API_TOKEN}
export KOSLI_PIPELINE=differ
export KOSLI_ENVIRONMENT="${1}"
export KOSLI_HOST="${2}"

# brew is not installed on Ubuntu 20.04, so can't directly do
# brew install kosli-dev/tap/kosli

image_name()
{
  VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  local -r VAR_NAME="CYBER_DOJO_${KOSLI_PIPELINE}_IMAGE"
  local -r IMAGE_NAME="${!VAR_NAME}"
  local -r IMAGE_TAG="${CIRCLE_SHA1:0:7}"
  echo ${IMAGE_NAME}:${IMAGE_TAG}
}

docker pull $(image_name)
install_kosli
kosli pipeline deployment report $(image_name) \
  --artifact-type docker

