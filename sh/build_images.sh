#!/bin/bash -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  export COMMIT_SHA="$(git_commit_sha)"
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha)
}

# - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm $(image_name):latest sh -c 'env | grep SHA='
}

# - - - - - - - - - - - - - - - - - - - - - -
build_images
if [ "SHA=$(git_commit_sha)" != "$(image_sha)" ]; then
  echo "ERROR: unexpected env-var inside image $(image_name):latest"
  echo "expected: 'SHA=$(git_commit_sha)'"
  echo "  actual: '$(image_sha)'"
  exit 42
fi
