#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed docker
export $(echo_versioner_env_vars)
docker compose --progress=plain up --wait --wait-timeout=10 client
copy_in_saver_test_data
TMP_HTML_FILENAME=/tmp/differ-demo.html
docker exec \
  "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}" \
    sh -c 'ruby /differ/html_demo.rb' \
      > ${TMP_HTML_FILENAME}
open "file://${TMP_HTML_FILENAME}"
