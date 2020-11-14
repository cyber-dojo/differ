
source "${SH_DIR}/augmented_docker_compose.sh"

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  build_images "${1}"
  tag_images_to_latest "${1}" # for cache till next build_tagged_images()
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:<none>" ]; then
        docker image rm "${image_name}"
      fi
    fi
  done
  docker system prune --force
}

# - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  if [ "${1}" == server ]; then
    local -r target=differ_server
  fi
  echo
  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha) "${target:-}"
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_sha_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - -
show_env_vars()
{
  echo "echo CYBER_DOJO_DIFFER_SHA=$(image_sha)"
  echo "echo CYBER_DOJO_DIFFER_TAG=$(image_tag)"
  echo
}

#- - - - - - - - - - - - - - - - - - - - - - - -
tag_images_to_latest()
{
  docker tag $(image_name):$(image_tag) $(image_name):latest
  if [ "${1}" != server ]; then
    docker tag ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:$(image_tag) ${CYBER_DOJO_DIFFER_CLIENT_IMAGE}:latest
  fi
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
