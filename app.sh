#!/bin/sh

docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"

app_up() {
  ${docker_compose_cmd} up
}

app_down() {
  ${docker_compose_cmd} down
}

if [ "$1" = 'up' ]; then
  app_up
fi

if [ "$1" = 'down' ]; then
  app_down
fi
