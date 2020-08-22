#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  docker-compose \
    --file "${SH_DIR}/../docker-compose.yml" \
    down \
    --remove-orphans \
    --volumes
}
