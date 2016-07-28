#!/bin/sh

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"
differ_client_container=differ_client

app_up() {
  cd differ_client && ./build-image.sh
  cd ..
  cd differ_server && ./build-image.sh
  cd ..
  ${docker_compose_cmd} up
}

app_sh() {
  docker exec --interactive --tty ${differ_client_container} sh
}

app_down() {
  ${docker_compose_cmd} down
}

if [ "$1" = 'up' ]; then
  app_up
fi

if [ "$1" = "sh" ]; then
  app_sh
fi

if [ "$1" = 'down' ]; then
  app_down
fi
