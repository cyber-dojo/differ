#!/bin/sh

# Don't do [set -e] because if [docker run ... && ./run.sh] fails
# I want the [docker cp] command to extract the coverage info

# Use 1: ./test.sh
#   Load and run all tests.
# Use 2: ./test.sh 347
#   Load all tests and run those whose hex-id includes 347
#   Use the test file's hex-id prefix to run *all* the tests in that file
#   Use the tests individual hex-id to run just that one test

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
${my_dir}/build.sh
if [ $? != 0 ]; then
  echo
  echo "./build.sh FAILED"
  exit 1
fi

export APP_DIR=/app
docker-compose down
docker-compose up -d

#docker ps -a

server_cid=`docker ps --all --quiet --filter "name=differ_server"`
docker exec ${server_cid} sh -c "cat Gemfile.lock"
docker exec ${server_cid} sh -c "cd test && ./run.sh ${*}"
server_status=$?
docker cp ${server_cid}:/tmp/coverage ${my_dir}
echo "coverage written to ${my_dir}/coverage"
cat ${my_dir}/coverage/done.txt

client_cid=`docker ps --all --quiet --filter "name=differ_client"`
docker exec ${client_cid} sh -c "cd test && ./run.sh ${*}"
client_status=$?

echo "SERVER_CID=${server_cid}"
echo "CLIENT_CID=${client_cid}"
echo "SERVER_STATUS=${server_status}"
echo "CLIENT_STATUS=${client_status}"

exit ${client_status} && ${server_status}
