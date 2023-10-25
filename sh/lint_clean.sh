#!/usr/bin/env bash
set -Eeu

repo_root()
{
  git rev-parse --show-toplevel
}

lint_clean()
{
  local -r LINT_EVIDENCE_DIR=/tmp/evidence/lint
  mkdir -p "${LINT_EVIDENCE_DIR}"
  cp "$(repo_root)/.rubocop.yml" "${LINT_EVIDENCE_DIR}"/.rubocop.yml
  ls -al "${LINT_EVIDENCE_DIR}"
  rubocop "$(repo_root)" | tee "${LINT_EVIDENCE_DIR}"/rubocop.log
}
export -f lint_clean