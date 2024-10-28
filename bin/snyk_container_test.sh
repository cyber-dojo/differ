#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed snyk
export $(echo_versioner_env_vars)
readonly image_name="cyberdojo/differ:${CYBER_DOJO_DIFFER_TAG}"
snyk container test "${image_name}" \
      --file="${ROOT_DIR}/Dockerfile" \
      --json-file-output="${ROOT_DIR}/snyk.container.scan.json" \
      --policy-path="${ROOT_DIR}/.snyk"
