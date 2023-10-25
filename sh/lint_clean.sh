#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"
source "${SH_DIR}/lib.sh"

sudo gem install rubocop --no-document
local -r LINT_EVIDENCE_DIR=/tmp/evidence/lint
mkdir -p "${LINT_EVIDENCE_DIR}"
cp "$(repo_root)/.rubocop.yml" "${LINT_EVIDENCE_DIR}"/.rubocop.yml
ls -al "${LINT_EVIDENCE_DIR}"
set +e
rubocop . | tee "${LINT_EVIDENCE_DIR}"/rubocop.log
