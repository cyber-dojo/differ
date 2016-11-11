#!/bin/bash

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

# Don't [set -e] because if
# [docker exec ... cd test && ./run.sh ${*}] fails
# I want the [docker cp] command to extract the coverage info

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed!"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

docker-compose -f ${my_dir}/client/docker-compose.yml build
if [ $? != 0 ]; then
  echo
  echo 'failed to build differ_client'
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

docker-compose -f ${my_dir}/server/docker-compose.yml build
if [ $? != 0 ]; then
  echo
  echo 'failed to build differ_server'
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

docker-compose down
docker-compose up -d

server_status=0
server_cid=`docker ps --all --quiet --filter "name=differ_server"`

client_status=0
client_cid=`docker ps --all --quiet --filter "name=differ_client"`

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests()
{
  #docker exec ${server_cid} sh -c "cat Gemfile.lock"
  docker exec ${server_cid} sh -c "cd test && ./run.sh ${*}"
  server_status=$?
  docker cp ${server_cid}:/tmp/coverage ${my_dir}/server
  echo "Coverage report copied to ${my_dir}/server/coverage"
  cat ${my_dir}/server/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  #docker exec ${client_cid} sh -c "cat Gemfile.lock"
  docker exec ${client_cid} sh -c "cd test && ./run.sh ${*}"
  client_status=$?
  docker cp ${client_cid}:/tmp/coverage ${my_dir}/client
  # Client Coverage is broken.
  # Simplecov is not seeing the client/test/src/server_test.rb file
  #echo "Coverage report copied to ${my_dir}/client/coverage"
  #cat ${my_dir}/client/coverage/done.txt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests ${*}
run_client_tests ${*}

if [[ ( ${server_status} == 0 && ${client_status} == 0 ) ]];  then
  docker-compose down
  echo "------------------------------------------------------"
  echo "All passed"
  exit 0
else
  echo
  echo "server: cid = ${server_cid}, status = ${server_status}"
  echo "client: cid = ${client_cid}, status = ${client_status}"
  echo
  exit 1
fi

