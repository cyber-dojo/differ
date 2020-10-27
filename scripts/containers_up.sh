#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
wait_briefly_until_healthy()
{
  local -r service_name="${1}"
  local -r max_tries=30
  printf "Waiting until ${service_name} is healthy"
  for n in $(seq ${max_tries})
  do
    if healthy ${service_name}; then
      printf '.OK\n'
      return
    else
      printf ".${n}"
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  printf "${service_name} not ready after ${max_tries} tries\n"
  local -r container_name="test_${service_name}"
  docker logs "${container_name}"
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  local -r container_name="${1}"
  docker ps --filter health=healthy --format '{{.Names}}' | grep -q "${container_name}"
}

# - - - - - - - - - - - - - - - - - - -
strip_known_warning()
{
  local -r docker_log="${1}"
  local -r known_warning="${2}"
  local stripped=$(echo -n "${docker_log}" | grep --invert-match -E "${known_warning}")
  if [ "${docker_log}" != "${stripped}" ]; then
    >&2 echo "SERVICE START-UP WARNING: ${known_warning}"
  else
    >&2 echo "SERVICE START-UP WARNING NOT FOUND: ${known_warning}"
  fi
  echo "${stripped}"
}

# - - - - - - - - - - - - - - - - - - -
exit_if_unclean()
{
  local -r service_name="${1}"
  local -r container_name="test_${service_name}"
  local server_log=$(docker logs "${container_name}" 2>&1)

  #local -r shadow_warning="server.rb:(.*): warning: shadowing outer local variable - filename"
  #server_log=$(strip_known_warning "${server_log}" "${shadow_warning}")
  #local -r mismatched_indent_warning="application(.*): warning: mismatched indentations at 'rescue' with 'begin'"
  #server_log=$(strip_known_warning "${server_log}" "${mismatched_indent_warning}")

  local -r line_count=$(echo -n "${server_log}" | grep --count '^')
  printf "Checking ${service_name} started cleanly..."
  # 3 lines on Thin (Unicorn=6, Puma=6)
  # Thin web server (v1.7.2 codename Bachmanity)
  # Maximum connections set to 1024
  # Listening on 0.0.0.0:4568, CTRL+C to stop
  if [ "${line_count}" == '6' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    echo_docker_log "${container_name}" "${server_log}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  local -r container_name="${1}"
  local -r docker_log="${2}"
  echo "[docker logs ${container_name}]"
  echo "<docker_log>"
  echo "${docker_log}"
  echo "</docker_log>"
}

# - - - - - - - - - - - - - - - - - - -
container_up_healthy_and_clean()
{
  local -r service_name="${1}"
  echo; container_up               "${service_name}"
  echo; wait_briefly_until_healthy "${service_name}"
  # Have to turn this off because health loop creates entres in log until model/saver are ready
  #echo; exit_if_unclean            "${service_name}"
}

# - - - - - - - - - - - - - - - - - - -
container_up()
{
  local -r service_name="${1}"
  augmented_docker_compose \
    up \
    --detach \
    --force-recreate \
      "${service_name}"
}

# - - - - - - - - - - - - - - - - - - -
containers_up()
{
  if [ "${1:-}" == 'server' ]; then
    container_up_healthy_and_clean differ_server
  else
    container_up_healthy_and_clean differ_client # TODO: add healthcheck to client Dockerfile
  fi
  copy_in_saver_test_data
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
