#!/bin/sh
set -e

export APP_DIR=/app
export CLIENT_PORT=4568
export SERVER_PORT=4567

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
cd ${my_dir} && ./build.sh
ip=$(docker-machine ip default)
echo "${ip}:${CLIENT_PORT}/diff"

docker-compose down
docker-compose up &
