#!/usr/bin/env bash
set -Eeu

repo_root()
{
  git rev-parse --show-toplevel
}
export -f repo_root

on_ci()
{
  [ -n "${CI:-}" ]
}
export -f on_ci

write_test_evidence_json()
{
  {
    echo '{ "server": '
    cat "$(repo_root)/test/reports/coverage.json"
    echo ', "client": '
    cat "$(repo_root)/client/test/reports/coverage.json"
    echo '}'
  } > "$(test_evidence_json_path)"
}
export -f write_test_evidence_json

test_evidence_json_path()
{
  echo "$(repo_root)/test/reports/evidence.json"
}
export -f test_evidence_json_path


