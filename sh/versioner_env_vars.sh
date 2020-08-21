#!/bin/bash -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  local -r tag="$(image_tag)"
  echo "${tag:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DIFFER_SHA="$(image_sha)"
  echo CYBER_DOJO_DIFFER_TAG="$(image_tag)"
  echo CYBER_DOJO_DIFFER_CLIENT_PORT=9999
  echo CYBER_DOJO_DIFFER_CLIENT_USER=nobody
  echo CYBER_DOJO_DIFFER_SERVER_USER=nobody
}
