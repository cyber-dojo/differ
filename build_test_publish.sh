#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/scripts"

source "${SH_DIR}/exit_zero_if_show_help.sh"
source "${SH_DIR}/generate_env_var_yml_files.sh"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/test_in_containers.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/on_ci_publish_tagged_images.sh"
source "${SH_DIR}/versioner_env_vars.sh"

export $(versioner_env_vars)
exit_zero_if_show_help "$@"
generate_env_var_yml_files
build_tagged_images
exit_zero_if_build_only "$@"
containers_up "$@"
test_in_containers "$@"
containers_down
on_ci_publish_tagged_images
