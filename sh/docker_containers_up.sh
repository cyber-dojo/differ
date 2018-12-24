#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=differ

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
  echo "${1} not ready after 5 seconds"
  docker logs ${1}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_ready "test-${MY_NAME}-server"
