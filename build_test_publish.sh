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
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_zero_if_show_help "$@"
generate_env_var_yml_files
build_tagged_images
check_embedded_env_var
show_env_vars
exit_zero_if_build_only "$@"
containers_up "$@"
exit_non_zero_unless_healthy
exit_non_zero_unless_started_cleanly
copy_in_saver_test_data
test_in_containers "$@"
containers_down
on_ci_publish_tagged_images
