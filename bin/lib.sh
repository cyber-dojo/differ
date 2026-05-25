
exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit_non_zero
    fi
  done
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit_non_zero
  fi
}

installed()
{
  if hash "${1}" &> /dev/null; then
    true
  else
    false
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero()
{
  kill -INT $$
}

containers_down()
{
  local -r all=$(docker ps --all --quiet)
  if [ -n "${all}" ]; then
    # shellcheck disable=SC2086
    docker rm --force ${all}
  fi
}

echo_warnings()
{
  local -r SERVICE_NAME="${1}"
  local -r DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)
  # Handle known warnings (eg waiting on Gem upgrade)
  # local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  # DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  if echo "${DOCKER_LOG}" | grep --quiet "warning" ; then
    echo "Warnings in ${SERVICE_NAME} container"
    echo "${DOCKER_LOG}"
  fi
}

strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local -r STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit_non_zero
  fi
  echo "${STRIPPED}"
}

remove_old_images()
{
  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep differ)
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DIFFER_CLIENT_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_DIFFER_IMAGE}"
  remove_all_but_latest "${dil}" cyberdojo/differ
}

remove_all_but_latest()
{
  # Keep latest in the cache
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  docker container prune --force
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      docker image rm --force "${image_name}"
    fi
  done
  docker system prune --force
}
