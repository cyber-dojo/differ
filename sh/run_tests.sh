#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(git rev-parse --show-toplevel)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/test_in_container.sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  server_up_healthy_and_clean "$@"
  client_up_healthy_and_clean "$@"
  copy_in_saver_test_data
  test_in_container "$@"
fi