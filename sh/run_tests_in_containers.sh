#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME="${ROOT_DIR##*/}"

readonly SERVER_CID=`docker ps --all --quiet --filter "name=${MY_NAME}_server"`
readonly CLIENT_CID=`docker ps --all --quiet --filter "name=${MY_NAME}_client"`

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests()
{
  docker exec ${SERVER_CID} sh -c "cd test && ./run.sh ${*}"
  server_status=$?
  docker cp ${SERVER_CID}:/tmp/coverage ${ROOT_DIR}/server
  echo "Coverage report copied to ${MY_NAME}/server/coverage"
  cat ${ROOT_DIR}/server/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  docker exec ${CLIENT_CID} sh -c "cd test && ./run.sh ${*}"
  client_status=$?
  docker cp ${CLIENT_CID}:/tmp/coverage ${ROOT_DIR}/client
  echo "Coverage report copied to ${MY_NAME}/client/coverage"
  cat ${ROOT_DIR}/client/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

server_status=0
client_status=0
run_server_tests ${*}
run_client_tests ${*}

if [[ ( ${server_status} == 0 && ${client_status} == 0 ) ]];  then
  echo "------------------------------------------------------"
  echo "All passed"
  ${ROOT_DIR}/sh/docker_containers_down.sh
  exit 0
else
  echo
  echo "server: cid = ${SERVER_CID}, status = ${server_status}"
  if [ "${server_status}" != "0" ]; then
    docker logs ${MY_NAME}_server
  fi
  echo "client: cid = ${CLIENT_CID}, status = ${client_status}"
  if [ "${client_status}" != "0" ]; then
    docker logs ${MY_NAME}_client
  fi
  echo
  exit 1
fi
