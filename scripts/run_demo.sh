#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SH_DIR}/generate_env_var_yml_files.sh"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

readonly TMP_HTML_FILENAME=/tmp/differ-demo.html

generate_env_var_yml_files
build_tagged_images
check_embedded_env_var
show_env_vars
containers_up
exit_non_zero_unless_healthy
exit_non_zero_unless_started_cleanly
copy_in_saver_test_data

docker exec \
  test-differ-client \
    sh -c 'ruby /differ/app/html_demo.rb' \
      > ${TMP_HTML_FILENAME}

open "file://${TMP_HTML_FILENAME}"

${SH_DIR}/containers_down.sh
