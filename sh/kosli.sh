#!/usr/bin/env bash
set -Eeu

# KOSLI_API_TOKEN env-var is set in the CI workflow yml
# KOSLI_HOST env-var is also set
export KOSLI_ORG=cyber-dojo
export KOSLI_FLOW=differ

kosli_create_flow()
{
  kosli create flow "${KOSLI_FLOW}" \
    --description="Diff files from two traffic-lights" \
    --template=artifact,lint,branch-coverage \
    --visibility=public
}

kosli_report_artifact()
{
  kosli report artifact "$(tagged_image_name)" \
      --artifact-type=docker \
      --repo-root="$(repo_root)"
}

kosli_report_lint_evidence()
{
  kosli report evidence commit generic \
    --compliant="${KOSLI_LINT_COMPLIANT}" \
    --evidence-paths=/tmp/evidence/lint \
    --name=lint
}

kosli_report_test_evidence()
{
  kosli report evidence artifact generic "$(tagged_image_name)" \
    --artifact-type=docker \
    --name=branch-coverage \
    --user-data="$(test_evidence_json_path)"
}

kosli_assert_artifact()
{
  kosli assert artifact "$(tagged_image_name)" \
    --artifact-type=docker
}

kosli_expect_deployment()
{
  # This is called from .github/workflows/kosli_deploy.yml
  # in the cyber-dojo/reusable-actions-workflows repo.
  local -r environment="${1}"
  local -r hostname="${2}"

  # In .github/workflows/main.yml deployment is its own job
  # and the image must be present to get its sha256 digest.
  docker pull "$(tagged_image_name)"

  kosli expect deployment "$(tagged_image_name)" \
    --artifact-type=docker \
    --environment="${environment}"
    --host="${hostname}"
}

on_ci_kosli_create_flow()
{
  if on_ci; then
    export KOSLI_HOST="${KOSLI_HOST_STAGING}"
    kosli_create_flow
    export KOSLI_HOST="${KOSLI_HOST_PRODUCTION}"
    kosli_create_flow
  fi
}

on_ci_kosli_report_artifact()
{
  if on_ci; then
    export KOSLI_HOST="${KOSLI_HOST_STAGING}"
    kosli_report_artifact
    export KOSLI_HOST="${KOSLI_HOST_PRODUCTION}"
    kosli_report_artifact
  fi
}

on_ci_kosli_report_lint_evidence()
{
  if on_ci; then
    export KOSLI_HOST="${KOSLI_HOST_STAGING}"
    kosli_report_lint_evidence
    export KOSLI_HOST="${KOSLI_HOST_PRODUCTION}"
    kosli_report_lint_evidence
  fi
}

on_ci_kosli_report_test_evidence()
{
  if on_ci; then
    write_test_evidence_json
    export KOSLI_HOST="${KOSLI_HOST_STAGING}"
    kosli_report_test_evidence
    export KOSLI_HOST="${KOSLI_HOST_PRODUCTION}"
    kosli_report_test_evidence
  fi
}

on_ci_kosli_assert_artifact()
{
  if on_ci; then
    export KOSLI_HOST="${KOSLI_HOST_STAGING}"
    kosli_assert_artifact
    export KOSLI_HOST="${KOSLI_HOST_PRODUCTION}"
    kosli_assert_artifact
  fi
}

on_ci()
{
  [ -n "${CI:-}" ]
}

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

write_test_evidence_json()
{
  echo '{ "server": ' > "$(test_evidence_json_path)"
  cat "${MY_DIR}/../test/reports/coverage.json" >> "$(test_evidence_json_path)"
  echo ', "client": ' >> "$(test_evidence_json_path)"
  cat "${MY_DIR}/../client/test/reports/coverage.json" >> "$(test_evidence_json_path)"
  echo '}' >> "$(test_evidence_json_path)"
}

test_evidence_json_path()
{
  echo "${MY_DIR}/../test/reports/evidence.json"
}

repo_root()
{
  # Functions in this file are called after sourcing the file
  # so repo_root() cannot use the path of this script.
  git rev-parse --show-toplevel
}

tagged_image_name()
{
  local -r VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  local -r VAR_NAME="CYBER_DOJO_${KOSLI_FLOW^^}_IMAGE"
  local -r IMAGE_NAME="${!VAR_NAME}"
  local -r IMAGE_TAG="${GITHUB_SHA:0:7}"
  echo ${IMAGE_NAME}:${IMAGE_TAG}
}
