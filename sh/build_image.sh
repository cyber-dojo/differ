#!/usr/bin/env bash
set -Eeu

export SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/check_embedded_sha_env_var.sh"
source "${SH_DIR}/echo_env_vars.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/tag_images_to_latest.sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

if on_ci ; then
  echo On CI so not re-building the image
  echo Instead, letting docker pull the built image
else
  echo Not on CI so building the image
  exit_non_zero_unless_installed docker
  remove_old_images
  build_tagged_images "$@"
  tag_images_to_latest "$@"
  check_embedded_sha_env_var
  echo_env_vars
fi
