#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SERVER_NAME="test-differ-server"

# - - - - - - - - - - - - - - - - - - -

wait_till_ready()
{
  local max_tries=20
  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:4567/sha"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  echo -n "Checking the service is ready"
  while [ $(( max_tries -= 1 )) -ge 0 ] ; do
    echo -n '.'
    if eval ${cmd} ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${1} not ready after 20 tries"
  docker logs ${1}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

exit_unless_started_cleanly()
{
  local docker_logs=$(docker logs "${SERVER_NAME}")
  if [[ ! -z "${docker_logs}" ]]; then
    echo "[docker log] not empty on startup"
    echo "<docker_log>"
    echo "${docker_logs}"
    echo "</docker_log>"
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_ready
exit_unless_started_cleanly
