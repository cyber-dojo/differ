#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

${my_dir}/build_docker_images.sh

docker-compose down

ip=$(docker-machine ip default)
echo "${ip}:4568"

docker-compose up &
