#!/usr/bin/env bash
set -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${MY_DIR}/kosli.sh"

# docker pull $(image_name)
# install_kosli
# kosli pipeline deployment report $(tagged_image_name) \
#   --artifact-type docker
#   --environment "${1}" \
#   --host "${2}"

kosli_log_deployment "$@"
