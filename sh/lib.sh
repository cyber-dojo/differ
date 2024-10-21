
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
  local -r SRC_PATH=${ROOT_DIR}/test/server/data/cyber-dojo
  local -r SAVER_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "saver")
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  pushd "${SRC_PATH}" || exit 99
  tar -c . | docker exec -i "${SAVER_CID}" tar x -C ${DEST_PATH}
  popd || exit 99
}

containers_down()
{
  docker compose down --remove-orphans --volumes
}

echo_versioner_env_vars()
{
  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
  echo COMMIT_SHA="${sha}"

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

exit_non_zero_unless_started_cleanly()
{
  echo
  local -r DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)

  # Handle known warnings (eg waiting on Gem upgrade)
  # local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  # DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  echo "Checking if ${SERVICE_NAME} started cleanly."
  local -r log_top5=$(echo "${DOCKER_LOG}" | head -5)
  if [ "${log_top5}" != "$(clean_top_5)" ]; then
    echo "${SERVICE_NAME} did not start cleanly."
    echo "First 10 lines of: docker logs ${CONTAINER_NAME}"
    echo
    echo "${DOCKER_LOG}" | head -10
    echo
    clean_top_5
    exit 42
  fi
}

clean_top_5()
{
  # 1st 5 lines on Puma
  local -r L1="Puma starting in single mode..."
  local -r L2='* Puma version: 6.4.3 (ruby 3.3.5-p100) ("The Eagle of Durango")'
  local -r L3="*  Min threads: 0"
  local -r L4="*  Max threads: 5"
  local -r L5="*  Environment: production"
  #
  local -r top5="$(printf "%s\n%s\n%s\n%s\n%s" "${L1}" "${L2}" "${L3}" "${L4}" "${L5}")"
  echo "${top5}"
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
