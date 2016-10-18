#!/bin/sh

# Don't do [set -e] because if
# [docker exec ... cd test && ./run.sh ${*}] fails
# I want the [docker cp] command to extract the coverage info

# Use 1: ./test.sh
#   Load and run all tests.
# Use 2: ./test.sh 347
#   Load all tests and run those whose hex-id includes 347
#   Use the test file's hex-id prefix to run *all* the tests in that file
#   Use the tests individual hex-id to run just that one test

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
app_dir=/app
client_port=4568
server_port=4567

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed!"
  exit 1
fi

${my_dir}/client/build-image.sh ${app_dir} ${client_port}
if [ $? != 0 ]; then
  echo
  echo "differ/client/build-image.sh FAILED"
  exit 1
fi

${my_dir}/server/build-image.sh ${app_dir} ${server_port}
if [ $? != 0 ]; then
  echo
  echo "differ/server/build-image.sh FAILED"
  exit 1
fi

cat ${my_dir}/docker-compose.yml.PORT \
  | sed "s/CLIENT_PORT/${client_port}/g" \
  | sed "s/SERVER_PORT/${server_port}/g" \
  > ${my_dir}/docker-compose.yml

docker-compose down
docker-compose up -d

server_cid=`docker ps --all --quiet --filter "name=differ_server"`
docker exec ${server_cid} sh -c "cat Gemfile.lock"
docker exec ${server_cid} sh -c "cd test && ./run.sh ${*}"
server_exit_status=$?
docker cp ${server_cid}:/tmp/coverage ${my_dir}/server
echo "Coverage report copied to ${my_dir}/server/coverage"
cat ${my_dir}/server/coverage/done.txt

client_cid=`docker ps --all --quiet --filter "name=differ_client"`
docker exec ${client_cid} sh -c "cd test && ./run.sh ${*}"
client_exit_status=$?
docker cp ${client_cid}:/tmp/coverage ${my_dir}/client

# Client Coverage is broken. Simplecov is not seeing the *_test.rb files
#echo "Coverage report copied to ${my_dir}/client/coverage"
#cat ${my_dir}/client/coverage/done.txt

echo
echo "server_cid = ${server_cid}"
echo "client_cid = ${client_cid}"
echo
echo "server_exit_status = ${server_exit_status}"
echo "client_exit_status = ${client_exit_status}"

exit ${client_exit_status} && ${server_exit_status}
