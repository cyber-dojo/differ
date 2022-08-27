#!/bin/bash -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${MY_DIR}/../scripts/kosli_log_deployment.sh" "${1}" "${2}"
