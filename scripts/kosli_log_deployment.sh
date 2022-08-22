#!/bin/bash -Eeu

brew install kosli-dev/tap/kosli

VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
export $(curl "${VERSIONER_URL}/app/.env")
export CYBER_DOJO_DIFFER_TAG="${CIRCLE_SHA1:0:7}"
docker pull ${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}

KOSLI_OWNER=cyber-dojo
KOSLI_API_TOKEN=${MERKELY_API_TOKEN}
KOSLI_PIPELINE=differ
KOSLI_ENVIRONMENT="${1}"
KOSLI_HOST="${2}"

kosli pipeline deployment report ${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG} \
  --artifact-type docker

