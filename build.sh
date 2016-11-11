#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose -f ${my_dir}/client/docker-compose.yml build
docker-compose -f ${my_dir}/server/docker-compose.yml build
