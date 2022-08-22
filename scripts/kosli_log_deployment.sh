#!/bin/bash -Eeu

# brew is not installed on Ubuntu 20.04, so can't directly do
# brew install kosli-dev/tap/kosli

sudo apt-get update
sudo apt-get install --yes wget
pushd /tmp
sudo wget https://github.com/kosli-dev/cli/releases/download/v0.1.8/kosli_0.1.8_linux_amd64.tar.gz
sudo tar -xf kosli_0.1.8_linux_amd64.tar.gz
sudo mv kosli /usr/local/bin
popd


VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
export $(curl "${VERSIONER_URL}/app/.env")
export CYBER_DOJO_DIFFER_TAG="${CIRCLE_SHA1:0:7}"
docker pull ${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}

export KOSLI_OWNER=cyber-dojo
export KOSLI_API_TOKEN=${MERKELY_API_TOKEN}
export KOSLI_PIPELINE=differ
export KOSLI_ENVIRONMENT="${1}"
export KOSLI_HOST="${2}"

kosli pipeline deployment report ${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG} \
  --artifact-type docker

