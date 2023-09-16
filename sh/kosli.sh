#!/usr/bin/env bash
set -Eeu

export KOSLI_FLOW=differ

# KOSLI_ORG is set in CI
# KOSLI_API_TOKEN is set in CI
# KOSLI_HOST_STAGING is set in CI
# KOSLI_HOST_PRODUCTION is set in CI
# SNYK_TOKEN is set in CI

kosli_create_flow()
{
  local -r hostname="${1}"

  kosli create flow "${KOSLI_FLOW}" \
    --description="Diff files from two traffic-lights" \
    --host="${hostname}" \
    --template=artifact,lint,branch-coverage,snyk-scan \
    --visibility=public
}

kosli_report_artifact()
{
  local -r hostname="${1}"

  kosli report artifact "$(tagged_image_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --repo-root="$(repo_root)"
}

kosli_report_lint_evidence()
{
  local -r hostname="${1}"

  kosli report evidence commit generic \
    --compliant="${KOSLI_LINT_COMPLIANT}" \
    --evidence-paths=/tmp/evidence/lint \
    --host="${hostname}" \
    --name=lint
}

kosli_report_test_evidence()
{
  local -r hostname="${1}"

  kosli report evidence artifact generic "$(tagged_image_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --name=branch-coverage \
    --user-data="$(test_evidence_json_path)"
}

kosli_report_snyk_evidence()
{
  local -r hostname="${1}"

  kosli report evidence artifact snyk "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}" \
      --name=snyk-scan \
      --scan-results="$(repo_root)/snyk.json"
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
    --environment="${environment}" \
    --host="${hostname}"
}

on_ci_kosli_create_flow()
{
  if on_ci; then
    kosli_create_flow "${KOSLI_HOST_STAGING}"
    kosli_create_flow "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_report_artifact()
{
  if on_ci; then
    kosli_report_artifact "${KOSLI_HOST_STAGING}"
    kosli_report_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_report_lint_evidence()
{
  if on_ci; then
    kosli_report_lint_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_lint_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_report_test_evidence()
{
  if on_ci; then
    write_test_evidence_json
    kosli_report_test_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_test_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_report_snyk_scan_evidence()
{
  if on_ci; then
    set +e
    snyk container test "$(artifact_name)" \
      --json-file-output="$(repo_root)/snyk.json" \
      --policy-path="$(repo_root)/.snyk"
    set -e

    kosli_report_snyk_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_snyk_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

artifact_name()
{
  source "$(repo_root)/sh/echo_versioner_env_vars.sh"
  export $(echo_versioner_env_vars)
  echo "${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}"
}

on_ci()
{
  [ -n "${CI:-}" ]
}

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

test_evidence_json_path()
{
  echo "$(repo_root)/test/reports/evidence.json"
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

repo_root()
{
  git rev-parse --show-toplevel
}
export -f repo_root
