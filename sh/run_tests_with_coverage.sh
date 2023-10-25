#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/exit_zero_if_demo_only.sh"
source "${SH_DIR}/lib.sh"
source "${SH_DIR}/on_ci_upgrade_docker_compose.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/tag_images_to_latest.sh"
source "${SH_DIR}/test_in_containers.sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

on_ci_upgrade_docker_compose
server_up_healthy_and_clean
client_up_healthy_and_clean "$@"
copy_in_saver_test_data
exit_zero_if_demo_only "$@"

test_in_containers "$@"
