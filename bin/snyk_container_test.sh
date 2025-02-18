#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed snyk
# shellcheck disable=SC2046
export $(echo_env_vars)
readonly IMAGE_NAME="${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}"

snyk container test "${IMAGE_NAME}" \
   --json-file-output="${ROOT_DIR}/snyk.container.scan.json" \
   --policy-path="${ROOT_DIR}/.snyk"

