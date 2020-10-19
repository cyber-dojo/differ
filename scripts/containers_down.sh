#!/bin/bash -Eeu

source "${SH_DIR}/augmented_docker_compose.sh"

# - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  echo
  augmented_docker_compose \
    down \
    --remove-orphans \
    --volumes
}
