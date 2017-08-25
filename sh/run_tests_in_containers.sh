#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
my_name="${ROOT_DIR##*/}"

readonly server_cid=`docker ps --all --quiet --filter "name=${my_name}_server"`
server_status=0

readonly client_cid=`docker ps --all --quiet --filter "name=${my_name}_client"`
client_status=0

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests()
{
  docker exec ${server_cid} sh -c "cd test && ./run.sh ${*}"
  server_status=$?
  docker cp ${server_cid}:/tmp/coverage ${ROOT_DIR}/server
  echo "Coverage report copied to ${my_name}/server/coverage"
  cat ${ROOT_DIR}/server/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  docker exec ${client_cid} sh -c "cd test && ./run.sh ${*}"
  client_status=$?
  docker cp ${client_cid}:/tmp/coverage ${ROOT_DIR}/client
  echo "Coverage report copied to ${my_name}/client/coverage"
  cat ${ROOT_DIR}/client/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests ${*}
run_client_tests ${*}

if [[ ( ${server_status} == 0 && ${client_status} == 0 ) ]];  then
  ${ROOT_DIR}/sh/docker_containers_down.sh
  echo "------------------------------------------------------"
  echo "All passed"
  exit 0
else
  echo
  echo "server: cid = ${server_cid}, status = ${server_status}"
  if [ "${server_cid}" != "0" ]; then
    docker logs ${my_name}_server
  fi
  echo "client: cid = ${client_cid}, status = ${client_status}"
  if [ "${client_cid}" != "0" ]; then
    docker logs ${my_name}_client
  fi
  echo
  exit 1
fi
