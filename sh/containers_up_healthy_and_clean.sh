
# - - - - - - - - - - - - - - - - - - -
server_up_healthy_and_clean()
{
  export SERVICE_NAME=differ_server
  export CONTAINER_NAME="${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}"
  export CONTAINER_PORT="${CYBER_DOJO_DIFFER_PORT}"
    docker-compose up --detach "${SERVICE_NAME}"
  exit_non_zero_unless_healthy
  exit_non_zero_unless_started_cleanly
}

# - - - - - - - - - - - - - - - - - - -
client_up_healthy_and_clean()
{
  if [ "${1:-}" != server ]; then
    export SERVICE_NAME=differ_client
    export CONTAINER_NAME="${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}"
    export CONTAINER_PORT="${CYBER_DOJO_DIFFER_CLIENT_PORT}"
    docker-compose up --detach "${SERVICE_NAME}"
    exit_non_zero_unless_healthy
    exit_non_zero_unless_started_cleanly
  fi
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_healthy()
{
  echo
  local -r MAX_TRIES=50
  printf "Waiting until ${SERVICE_NAME} is healthy"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy; then
      echo; echo "${SERVICE_NAME} is healthy."
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo; echo "${SERVICE_NAME} not healthy after ${MAX_TRIES} tries."
  echo_docker_log
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
  local DOCKER_LOG=$(echo_docker_log)

  # Handle known warnings (eg waiting on Gem upgrade)
  #local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  #DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  echo "Checking if ${SERVICE_NAME} started cleanly."
  local -r log_top5=$(echo "${DOCKER_LOG}" | head -5)
  if [ "${log_top5}" = "$(clean_top_5)" ]; then
    echo "${SERVICE_NAME} started cleanly."
  else
    echo "${SERVICE_NAME} did not start cleanly."
    echo "First 10 lines of: docker logs ${CONTAINER_NAME}"
    echo
    echo "${DOCKER_LOG}" | head -10
    echo
    clean_top_5
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - -
clean_top_5()
{
  # 1st 5 lines on Puma
  local -r L1="Puma starting in single mode..."
  local -r L2='* Puma version: 6.4.2 (ruby 3.3.0-p0) ("The Eagle of Durango")'
  local -r L3="*  Min threads: 0"
  local -r L4="*  Max threads: 5"
  local -r L5="*  Environment: production"
  #
  local -r top5="$(printf "%s\n%s\n%s\n%s\n%s" "${L1}" "${L2}" "${L3}" "${L4}" "${L5}")"
  echo "${top5}"
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  docker logs "${CONTAINER_NAME}" 2>&1
}

# - - - - - - - - - - - - - - - - - - -
strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit 42
  fi
  echo "${STRIPPED}"
}
