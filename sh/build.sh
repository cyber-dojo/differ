#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/exit_zero_if_show_help.sh"
source "${SH_DIR}/on_ci_upgrade_docker_compose.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/tag_images_to_latest.sh"
source "${SH_DIR}/lib.sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_non_zero_unless_installed docker
exit_non_zero_unless_installed docker-compose
on_ci_upgrade_docker_compose
remove_old_images
build_tagged_images "$@"
tag_images_to_latest "$@"
