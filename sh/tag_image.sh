#!/bin/bash -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
sha()
{
  local -r tag="$(tag)"
  echo "${tag:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_image()
{
  docker tag $(image_name):latest $(image_name):$(tag)
  echo
  echo "CYBER_DOJO_DIFFER_SHA=$(sha)"
  echo "CYBER_DOJO_DIFFER_TAG=$(tag)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_image
