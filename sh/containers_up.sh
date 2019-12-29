#!/bin/bash
set -e

# - - - - - - - - - - - - - - - - - - - - - -
ip_address_slow()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}
readonly IP_ADDRESS=$(ip_address_slow)

# - - - - - - - - - - - - - - - - - - - - - -
wait_briefly_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=10
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    if ready ${port}; then
      printf '.OK\n'
      return
    else
      printf '.'
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  printf "${name} not ready after ${max_tries} tries\n"
  if [ -f "$(ready_response_filename)" ]; then
    printf "$(ready_response)\n"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r ready_cmd="\
    curl \
      --output $(ready_response_filename) \
      --silent \
      --fail \
      -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "$(ready_response_filename)"
  if ${ready_cmd} && [ "$(ready_response)" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - -
ready_response()
{
  cat "$(ready_response_filename)"
}

# - - - - - - - - - - - - - - - - - - -
ready_response_filename()
{
  printf /tmp/curl-differ-ready-output
}

# - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local -r docker_log=$(docker logs "${name}" 2>&1)
  local -r known_warning="daemons-1.3.1(.*)warning\: mismatched indentations at 'rescue'"
  local -r stripped=$(echo -n "${docker_log}" | grep --invert-match -E "${known_warning}")
  if [ "${docker_log}" == "${stripped}" ]; then
    echo "WARNING: expected to find warning: ${known_warning}"
    #exit 42
  fi
  local -r line_count=$(echo -n "${stripped}" | grep --count '^')
  printf "Checking ${name} started cleanly..."
  # 3 lines on Thin (Unicorn=6, Puma=6)
  # Thin web server (v1.7.2 codename Bachmanity)
  # Maximum connections set to 1024
  # Listening on 0.0.0.0:4568, CTRL+C to stop
  if [ "${line_count}" == '3' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    echo_docker_log "${name}" "${docker_log}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  echo "[docker logs ${name}]"
  echo "<docker_log>"
  echo "${docker_log}"
  echo "</docker_log>"
}

# - - - - - - - - - - - - - - - - - - -
container_up_ready_and_clean()
{
  local -r root_dir="${1}"
  local -r service_name="${2}"
  local -r container_name="test-${service_name}"
  local -r port="${3}"
  printf '\n'
  docker-compose \
    --file "${root_dir}/docker-compose.yml" \
    up \
    --detach \
    --force-recreate \
      "${service_name}"
  wait_briefly_until_ready "${container_name}" "${port}"
  exit_unless_clean "${container_name}"
}

# - - - - - - - - - - - - - - - - - - -
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export NO_PROMETHEUS=true
container_up_ready_and_clean "${ROOT_DIR}" differ-server 4567
if [ "${1}" != 'server' ]; then
  container_up_ready_and_clean "${ROOT_DIR}" differ-client 4568
fi
