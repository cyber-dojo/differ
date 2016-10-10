#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
app_dir=/app
client_port=4568
server_port=4567

${my_dir}/build.sh ${app_dir} ${client_port} ${server_port}
ip=$(docker-machine ip default)
echo "${ip}:${client_port}"

export CLIENT_PORT=${client_port}
export SERVER_PORT=${server_port}
docker-compose down
docker-compose up &
