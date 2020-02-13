#!/bin/bash -Eeu

if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
  echo
  echo 'Use: pipe_build_up_test.sh [client|server] [HEX-ID...]'
  echo 'Options:'
  echo '   client  - only run the tests from inside the client'
  echo '   server  - only run the tests from inside the server'
  echo '   HEX-ID  - only run the tests matching this identifier'
  exit 0
fi

readonly SH_DIR="$( cd "$( dirname "${0}" )/sh" && pwd )"
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)
${SH_DIR}/build_images.sh "$@"
${SH_DIR}/containers_up.sh "$@"
${SH_DIR}/test_in_containers.sh "$@"
${SH_DIR}/containers_down.sh
${SH_DIR}/tag_image.sh
${SH_DIR}/on_ci_publish_images.sh
