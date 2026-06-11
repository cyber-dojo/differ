#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)
exit_non_zero_unless_installed docker

# Each demo runs as its own docker-compose project so this repo's demo can
# run alongside a sibling repo's demo (eg web) without their networks or
# container names colliding. differ publishes no host ports - the demo execs
# into the client container, and the client reaches the server over the
# project's private network. Override to run a second differ demo alongside
# the first, eg:
#   COMPOSE_PROJECT_NAME=differ2 bin/demo.sh
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-differ}"

docker compose --progress=plain up --wait --wait-timeout=10 client
TMP_HTML_FILENAME=/tmp/differ-demo.html
docker exec \
  "$(service_container client)" \
    sh -c 'ruby /differ/source/html_demo.rb' \
      > ${TMP_HTML_FILENAME}
open "file://${TMP_HTML_FILENAME}"
