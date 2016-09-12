#!/bin/sh
set -e

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
cd ${MY_DIR} && ./build.sh
ip=$(docker-machine ip default)
echo "${ip}:4568/diff"
docker-compose up &
