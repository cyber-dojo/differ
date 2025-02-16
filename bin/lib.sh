
echo_base_image()
{
  #local -r json="$(curl --fail --silent --request GET https://beta.cyber-dojo.org/differ/base_image)"
  #echo "${json}" | jq -r '.base_image'
  echo cyberdojo/sinatra-base:db948c1
}

echo_env_vars()
{
  # Set env-vars for this repos differ service
  if [[ ! -v BASE_IMAGE ]] ; then
    echo BASE_IMAGE="$(echo_base_image)"  # --build-arg ...
  fi
  if [[ ! -v COMMIT_SHA ]] ; then
    local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
    echo COMMIT_SHA="${sha}"  # --build-arg ...
  fi

  # Setup port env-vars in .env file using versioner
  local -r env_filename="${ROOT_DIR}/.env"
  echo "# This file is generated in bin/lib.sh echo_env_vars()" > "${env_filename}"
  echo "CYBER_DOJO_DIFFER_CLIENT_PORT=9999"                    >> "${env_filename}"
  docker run --rm cyberdojo/versioner | grep PORT              >> "${env_filename}"

  # From versioner ...
  docker run --rm cyberdojo/versioner

  echo CYBER_DOJO_DIFFER_SHA="${sha}"
  echo CYBER_DOJO_DIFFER_TAG="${sha:0:7}"
  #
  echo CYBER_DOJO_DIFFER_CLIENT_IMAGE=cyberdojo/differ-client
  echo CYBER_DOJO_DIFFER_CLIENT_PORT=9999
  #
  echo CYBER_DOJO_DIFFER_CLIENT_USER=nobody
  echo CYBER_DOJO_DIFFER_SERVER_USER=nobody
  #
  echo CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME=test_differ_client
  echo CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME=test_differ_server
  #
  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_DIFFER_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/differ"
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit 42
    fi
  done
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit 42
  fi
}

exit_non_zero_if_bad_base_image()
{
  # Called in setup job in .github/workflows/main.yml
  local -r base_image="${1}"
  local -r regex=":[a-z0-9]{7}@sha256:[a-z0-9]{64}$"
  if [[ ${base_image} =~ $regex ]]; then
    echo "PASSED: base_image=${base_image}"
  else
    stderr "base_image=${base_image}"
    stderr "must have a 7-digit short-sha tag and a full 64-digit digest, Eg"
    stderr "  name  : cyberdojo/sinatra-base"
    stderr "  tag   : 559d354"
    stderr "  digest: ddab9080cd0bbd8e976a18bdd01b37b66e47fe83b0db396e65dc3014bad17fd3"
    exit 42
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

copy_in_saver_test_data()
{
  local -r SAVER_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "saver")
  local -r SRC_PATH=${ROOT_DIR}/test/server/data/cyber-dojo
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  tar --no-xattrs -c -C "${SRC_PATH}" - . | docker exec -i "${SAVER_CID}" tar x -C ${DEST_PATH}
}

containers_down()
{
  docker compose down --remove-orphans --volumes
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
    exit 42
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
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:")
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      docker image rm "${image_name}"
    fi
  done
  docker system prune --force
}
