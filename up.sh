#!/bin/sh
set -e

docker images --quiet --filter=dangling=true | xargs docker rmi
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
cd ${MY_DIR} && ./build.sh
ip=$(docker-machine ip default)
echo "${ip}:4568/diff"
docker-compose up &
