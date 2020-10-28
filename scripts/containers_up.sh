#!/bin/bash -Eeu

server_service_name() { echo differ_server; }
client_service_name() { echo differ_client; }
server_container_name() { echo "${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}"; }
client_container_name() { echo "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}"; }
line() { echo ---------------------------; }

# - - - - - - - - - - - - - - - - - - -
containers_up()
{
  if [ "${1:-}" == 'server' ]; then
    container_up_healthy_and_clean $(server_service_name) $(server_container_name)
  else
    container_up_healthy_and_clean $(client_service_name) $(client_container_name)
  fi
  copy_in_saver_test_data
}

# - - - - - - - - - - - - - - - - - - -
container_up_healthy_and_clean()
{
  local -r SERVICE_NAME="${1}"
  local -r CONTAINER_NAME="${2}"
  echo; container_up               "${SERVICE_NAME}"
  echo; wait_briefly_until_healthy "${SERVICE_NAME}" "${CONTAINER_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
container_up()
{
  local -r SERVICE_NAME="${1}"
  augmented_docker_compose \
    up \
    --detach \
    --force-recreate \
      "${SERVICE_NAME}"
}

# - - - - - - - - - - - - - - - - - - - - - -
wait_briefly_until_healthy()
{
  local -r SERVICE_NAME="${1}"
  local -r CONTAINER_NAME="${2}"
  local -r MAX_TRIES=30
  printf "Waiting until ${SERVICE_NAME} is healthy"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy ${SERVICE_NAME}; then
      printf '.OK\n'
      return
    else
      printf .
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  printf "${SERVICE_NAME} not ready after ${MAX_TRIES} tries\n"
  echo_docker_log_if_unclean "${SERVICE_NAME}" "${CONTAINER_NAME}"
  echo_probe_fail_log "${CONTAINER_NAME}"
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  local -r CONTAINER_NAME="${1}"
  docker ps --filter health=healthy --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log_if_unclean()
{
  local -r SERVICE_NAME="${1}"
  local -r CONTAINER_NAME="${2}"
  local DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)

  #local -r shadow_warning="server.rb:(.*): warning: shadowing outer local variable - filename"
  #server_log=$(strip_known_warning "${server_log}" "${shadow_warning}")
  #local -r mismatched_indent_warning="application(.*): warning: mismatched indentations at 'rescue' with 'begin'"
  #server_log=$(strip_known_warning "${server_log}" "${mismatched_indent_warning}")

  printf "Checking ${SERVICE_NAME} started cleanly..."
  local -r LINE_COUNT=$(echo -n "${DOCKER_LOG}" | grep --count '^')
  # 3 lines on Thin (Unicorn=6, Puma=6)
  # Thin web server (v1.7.2 codename Bachmanity)
  # Maximum connections set to 1024
  # Listening on 0.0.0.0:4568, CTRL+C to stop
  if [ "${LINE_COUNT}" == '6' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    echo "docker logs ${CONTAINER_NAME}"
    echo "$(line)"
    echo "${DOCKER_LOG}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
echo_probe_fail_log()
{
  local -r CONTAINER_NAME="${1}"
  local -r COMMAND="docker exec -it "${CONTAINER_NAME}" bash -c 'cat /tmp/ready.fail.log'"
  echo Echoing readiness log file
  echo "${COMMAND}"
  echo "$(line)"
  eval "${COMMAND}"
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
