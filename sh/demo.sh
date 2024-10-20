#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/sh/lib.sh"

demo()
{
  local -r TMP_HTML_FILENAME=/tmp/differ-demo.html
  docker exec \
    "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}" \
      sh -c 'ruby /differ/app/html_demo.rb' \
        > ${TMP_HTML_FILENAME}
  open "file://${TMP_HTML_FILENAME}"
}

exit_non_zero_unless_installed docker
export $(echo_versioner_env_vars)
server_up_healthy_and_clean
client_up_healthy_and_clean "$@"
copy_in_saver_test_data
demo
