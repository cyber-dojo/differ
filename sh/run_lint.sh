#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source "${SH_DIR}/lib.sh"

run_lint()
{
  sudo gem install rubocop --no-document
  local -r LINT_EVIDNCE_DIR=/tmp/evidence/lint
  mkdir -p "${LINT_EVIDNCE_DIR}"
  cp "$(repo_root)/.rubocop.yml" "${LINT_EVIDNCE_DIR}"/.rubocop.yml
  ls -al "${LINT_EVIDNCE_DIR}"
  set +e
  rubocop . | tee "${LINT_EVIDNCE_DIR}"/rubocop.log
  local -r STATUS=$?
  set -e

  if [ "${STATUS}" == "0" ]; then
    export KOSLI_LINT_COMPLIANT="true"
  else
    export KOSLI_LINT_COMPLIANT="false"
  fi
}

run_lint