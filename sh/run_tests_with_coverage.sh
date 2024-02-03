#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(git rev-parse --show-toplevel)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/lib.sh"
source "${SH_DIR}/on_ci_upgrade_docker_compose.sh"
source "${SH_DIR}/test_in_containers.sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

run_tests_with_coverage()
{
  exit_code=0
  on_ci_upgrade_docker_compose
  server_up_healthy_and_clean
  client_up_healthy_and_clean "$@"
  copy_in_saver_test_data
  test_in_containers "$@" || exit_code=$?
  write_test_evidence_json
  return ${exit_code}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_tests_with_coverage "$@"
fi