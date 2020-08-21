#!/bin/bash -Eeu
readonly MY_NAME=`basename "${BASH_SOURCE[0]}"`
readonly SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/sh" && pwd)"
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - -
main()
{
  local -r client_user="${CYBER_DOJO_DIFFER_CLIENT_USER}"
  local -r server_user="${CYBER_DOJO_DIFFER_SERVER_USER}"
  show_help_if_requested "$@"
  ${SH_DIR}/build_images.sh "$@"
  ${SH_DIR}/tag_image.sh
  ${SH_DIR}/containers_up.sh "$@"
  ${SH_DIR}/test_in_containers.sh "${client_user}" "${server_user}" "$@"
  ${SH_DIR}/containers_down.sh
  ${SH_DIR}/on_ci_publish_images.sh
}

#- - - - - - - - - - - - - - - - - - - - - -
show_help_if_requested()
{
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
main "$@"
