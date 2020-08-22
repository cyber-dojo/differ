#!/bin/bash -Eeu

export SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/sh" && pwd)"
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)
source ${SH_DIR}/build_tagged_images.sh
source ${SH_DIR}/containers_up.sh
source ${SH_DIR}/test_in_containers.sh
source ${SH_DIR}/containers_down.sh
source ${SH_DIR}/on_ci_publish_images.sh

#- - - - - - - - - - - - - - - - - - - - - -
build_test_publish()
{
  show_help_if_requested "$@"
  build_tagged_images "$@"
  containers_up "$@"
  test_in_containers "$@"
  containers_down
  on_ci_publish_images
}

#- - - - - - - - - - - - - - - - - - - - - -
show_help_if_requested()
{
  local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
  if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
    echo
    echo "Use: ${MY_NAME} [client|server] [ID...]"
    echo 'Options:'
    echo '   client  - only run the tests from inside the client'
    echo '   server  - only run the tests from inside the server'
    echo '   ID...   - only run the tests matching these identifiers'
    echo
    exit 0
  fi
}

#- - - - - - - - - - - - - - - - - - - - - -
build_test_publish "$@"
