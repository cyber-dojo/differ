#!/usr/bin/env bash
set -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export KOSLI_ORG=cyber-dojo
export KOSLI_FLOW=differ

export KOSLI_HOST_STAGING=https://staging.app.kosli.com
export KOSLI_HOST_PRODUCTION=https://app.kosli.com

# - - - - - - - - - - - - - - - - - - -
tagged_image_name()
{
  local -r VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  local -r VAR_NAME="CYBER_DOJO_${KOSLI_PIPELINE^^}_IMAGE"
  local -r IMAGE_NAME="${!VAR_NAME}"
  local -r IMAGE_TAG="${GITHUB_SHA:0:7}"
  echo ${IMAGE_NAME}:${IMAGE_TAG}
}

# - - - - - - - - - - - - - - - - - - -
kosli_create_flow()
{
  kosli create flow "${KOSLI_FLOW}" \
    --description "Diff files from two traffic-lights" \
    --host "${1}" \
    --template artifact,branch-coverage \
    --visibility public
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_artifact()
{
  local -r hostname="${1}"

  pushd "$(root_dir)" > /dev/null

  kosli report artifact "$(tagged_image_name)" \
      --artifact-type docker \
      --host "${hostname}"

  popd > /dev/null
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_lint()
{
  # TODO
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_evidence()
{
  local -r hostname="${1}"

  kosli report evidence artifact generic "$(tagged_image_name)" \
    --artifact-type docker \
    --description "server & client branch-coverage reports" \
    --evidence-type branch-coverage \
    --host "${hostname}" \
    --user-data "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
write_evidence_json()
{
  echo '{ "server": ' > "$(evidence_json_path)"
  cat "${MY_DIR}/../test/reports/coverage.json" >> "$(evidence_json_path)"
  echo ', "client": ' >> "$(evidence_json_path)"
  cat "${MY_DIR}/../client/test/reports/coverage.json" >> "$(evidence_json_path)"
  echo '}' >> "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
evidence_json_path()
{
  echo "${MY_DIR}/../test/reports/evidence.json"
}

# - - - - - - - - - - - - - - - - - - -
kosli_expect_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

  # In .github/workflows/main.yml deployment is its own job
  # and the image must be present to get its sha256 fingerprint.
  docker pull "$(tagged_image_name)"

  kosli expect deployment "$(tagged_image_name)" \
    --artifact-type docker \
    --description "Deployed to ${environment} in Github Actions pipeline" \
    --environment "${environment}" \
    --host "${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_assert_artifact()
{
  local -r hostname="${1}"

  kosli assert artifact "$(tagged_image_name)" \
      --artifact-type docker \
      --host "${hostname}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_create_flow()
{
  if on_ci; then
    kosli_create_flow "${KOSLI_HOST_STAGING}"
    kosli_create_flow "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_artifact()
{
  if on_ci; then
    kosli_report_artifact "${KOSLI_HOST_STAGING}"
    kosli_report_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_lint()
{
  if on_ci; then
    kosli_report_lint "${KOSLI_HOST_STAGING}"
    kosli_report_lint "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_evidence()
{
  if on_ci; then
    write_evidence_json
    kosli_report_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
root_dir()
{
  # Functions in this file are called after sourcing (not including)
  # this file so root_dir() cannot use the path of this script.
  git rev-parse --show-toplevel
}