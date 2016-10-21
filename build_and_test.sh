#!/bin/sh

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

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
app_dir=/app
client_port=4568
server_port=4567

# - - - - - - - - - - - - - - - - - - - - - - - - - -

${my_dir}/client/build-image.sh ${app_dir} ${client_port}
if [ $? != 0 ]; then
  echo
  echo "differ/client/build-image.sh FAILED"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

${my_dir}/server/build-image.sh ${app_dir} ${server_port}
if [ $? != 0 ]; then
  echo
  echo "differ/server/build-image.sh FAILED"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

docker-compose down
docker-compose up -d

# - - - - - - - - - - - - - - - - - - - - - - - - - -

server_cid=`docker ps --all --quiet --filter "name=differ_server"`
#docker exec ${server_cid} sh -c "cat Gemfile.lock"
docker exec ${server_cid} sh -c "cd test && ./run.sh ${*}"
server_exit_status=$?
docker cp ${server_cid}:/tmp/coverage ${my_dir}/server
echo "Coverage report copied to ${my_dir}/server/coverage"
cat ${my_dir}/server/coverage/done.txt

# - - - - - - - - - - - - - - - - - - - - - - - - - -

client_cid=`docker ps --all --quiet --filter "name=differ_client"`
#docker exec ${client_cid} sh -c "cat Gemfile.lock"
docker exec ${client_cid} sh -c "cd test && ./run.sh ${*}"
client_exit_status=$?
docker cp ${client_cid}:/tmp/coverage ${my_dir}/client
# Client Coverage is broken.
# Simplecov is not seeing the client/test/src/server_test.rb file
#echo "Coverage report copied to ${my_dir}/client/coverage"
#cat ${my_dir}/client/coverage/done.txt

# - - - - - - - - - - - - - - - - - - - - - - - - - -

show_cids() {
  echo
  echo "server: cid = ${server_cid}, exit_status = ${server_exit_status}"
  echo "client: cid = ${client_cid}, exit_status = ${client_exit_status}"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ ${client_exit_status} != 0 ]; then
  show_cids
  exit 1
fi

if [ ${server_exit_status} != 0 ]; then
  show_cids
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

echo
echo "All passed. Removing differ containers..."
docker-compose down 2>/dev/null
