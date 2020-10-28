#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - -
containers_up()
{
  if [ "${1:-}" == 'server' ]; then
    export SERVICE_NAME=differ_server
    export CONTAINER_NAME="${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}"
  else
    export SERVICE_NAME=differ_client
    export CONTAINER_NAME="${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}"
  fi
  echo; augmented_docker_compose up --detach --force-recreate "${SERVICE_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_healthy()
{
  echo
  local -r MAX_TRIES=30
  printf "Waiting until ${SERVICE_NAME} is healthy"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy; then
      echo .OK
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo FAIL
  echo "${SERVICE_NAME} not ready after ${MAX_TRIES} tries"
  local -r COMMAND="docker exec -it "${CONTAINER_NAME}" bash -c 'cat /tmp/ready.fail.log'"
  echo Echoing readiness log file
  echo "${COMMAND}"
  echo
  eval "${COMMAND}"
  echo
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  docker ps --filter health=healthy --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_started_cleanly()
{
  echo
  printf "Checking ${SERVICE_NAME} started cleanly..."
  local DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)
  #local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  #DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")
  local -r LINE_COUNT=$(echo -n "${DOCKER_LOG}" | grep --count '^')
  # 3 lines on Thin (Unicorn=6, Puma=6)
  # Thin web server (v1.7.2 codename Bachmanity)
  # Maximum connections set to 1024
  # Listening on 0.0.0.0:4568, CTRL+C to stop
  if [ "${LINE_COUNT}" == '6' ]; then
    echo OK
  else
    echo FAIL
    echo "docker logs ${CONTAINER_NAME}"
    echo
    echo "${DOCKER_LOG}"
    echo
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    >&2 echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    >&2 echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
  fi
  echo "${STRIPPED}"
}

# - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  local -r SRC_PATH=${ROOT_DIR}/test/data/cyber-dojo
  local -r SAVER_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "saver")
  local -r DEST_PATH=/cyber-dojo
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}
}
