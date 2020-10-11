#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    down \
    --remove-orphans \
    --volumes
}
