#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

tag()
{
  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
  echo "${sha:0:7}"
}

tag_image()
{
  docker tag $(image_name):latest $(image_name):$(tag)
}

tag_image
