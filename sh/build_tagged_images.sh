#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  remove_current_docker_image "${CYBER_DOJO_DIFFER_IMAGE}"
  remove_current_docker_image "${CYBER_DOJO_DIFFER_CLIENT_IMAGE}"

  docker-compose \
    --file "${SH_DIR}/../docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha)

  docker tag $(image_name):$(image_tag) $(image_name):latest
  docker tag ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:$(image_tag) ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:latest

  check_embedded_env_var
  echo
  echo "CYBER_DOJO_DIFFER_TAG=$(image_tag)"
  echo "CYBER_DOJO_DIFFER_SHA=$(image_sha)"
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_current_docker_image()
{
  local -r name="${1}"
  if image_exists "${name}" 'latest' ; then
    local -r sha="$(docker run --rm -it ${name}:latest sh -c 'echo -n ${SHA}')"
    local -r tag="${sha:0:7}"
    if image_exists "${name}" "${tag}" ; then
      echo "Deleting current image ${name}:${tag}"
      docker image rm "${name}:${tag}"
    fi
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
image_exists()
{
  local -r name="${1}"
  local -r tag="${2}"
  local -r latest=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep "${name}:${tag}")
  [ "${latest}" != '' ]
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
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
  docker run --rm $(image_name):$(image_tag) sh -c 'echo -n ${SHA}'
}
