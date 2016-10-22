#!/bin/sh
set -e

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

ip=$(docker-machine ip default)
echo "${ip}:${client_port}"

docker-compose down
docker-compose up &
