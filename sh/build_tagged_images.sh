#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  export COMMIT_SHA="$(git_commit_sha)"
  docker-compose \
    --file "${SH_DIR}/../docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha)

  if [ "SHA=$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: '$(sha_in_image)'"
    exit 42
  else
    echo
    echo "CYBER_DOJO_DIFFER_TAG=$(image_tag)"
    echo "CYBER_DOJO_DIFFER_SHA=$(image_sha)"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${SH_DIR}" && git rev-parse HEAD)
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
  docker run --rm $(image_name):$(image_tag) sh -c 'env | grep SHA='
}
