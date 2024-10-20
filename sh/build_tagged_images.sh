#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  if [ "${1:-}" = server ]; then
    local -r target=differ_server
  fi
  echo
  docker compose build --build-arg COMMIT_SHA="$(git_commit_sha)" ${target:-}
}

# - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

# - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  echo "${CYBER_DOJO_DIFFER_TAG}"
}

# - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  echo "${CYBER_DOJO_DIFFER_SHA}"
}

# - - - - - - - - - - - - - - - - - - - - - -
sha_in_image()
{
  docker run --rm $(image_name):$(image_tag) sh -c 'echo -n ${SHA}'
}
