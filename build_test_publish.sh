#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/scripts"

source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/check_embedded_sha_env_var.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/echo_env_vars.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/exit_zero_if_demo_only.sh"
source "${SH_DIR}/exit_zero_if_show_help.sh"
source "${SH_DIR}/generate_env_var_yml_files.sh"
source "${SH_DIR}/on_ci_publish_tagged_images.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/tag_images_to_latest.sh"
source "${SH_DIR}/test_in_containers.sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_zero_if_show_help "$@"
exit_non_zero_unless_installed docker
exit_non_zero_unless_installed docker-compose
remove_old_images
#generate_env_var_yml_files
build_tagged_images "$@"
tag_images_to_latest "$@"
check_embedded_sha_env_var
exit_zero_if_build_only "$@"
server_up_healthy_and_clean
client_up_healthy_and_clean "$@"
copy_in_saver_test_data
exit_zero_if_demo_only "$@"
test_in_containers "$@"
containers_down
on_ci_publish_tagged_images
echo_env_vars
