#!/bin/sh

#my_dir="$( cd "$( dirname "${0}" )" && pwd )"
#docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"

cd client && ./build-image.sh
cd ..
cd server && ./build-image.sh
cd ..
docker-compose up
