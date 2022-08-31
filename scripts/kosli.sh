#!/usr/bin/env bash
set -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export KOSLI_PIPELINE=differ
export KOSLI_STAGING_HOSTNAME=https://staging.app.kosli.com
export KOSLI_PROD_HOSTNAME=https://app.kosli.com

# - - - - - - - - - - - - - - - - - - -
install_kosli()
{
  if ! hash kosli; then
    sudo sh -c 'echo "deb [trusted=yes] https://apt.fury.io/kosli/ /"  > /etc/apt/sources.list.d/fury.list'
    sudo apt install ca-certificates
    sudo apt update
    sudo apt install kosli
  fi
}

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
kosli_declare_pipeline()
{
  kosli pipeline declare \
    --description "Diff files from two traffic-lights" \
    --host "${1}" \
    --template artifact,branch-coverage \
    --visibility public
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_declare_pipeline()
{
  if ! on_ci ; then
    return
  fi
  install_kosli
  kosli_declare_pipeline "${KOSLI_STAGING_HOSTNAME}"
  kosli_declare_pipeline "${KOSLI_PROD_HOSTNAME}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_log_artifact()
{
  kosli pipeline artifact report creation $(tagged_image_name) \
    --artifact-type docker \
    --host "${1}"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_log_artifact()
{
  if ! on_ci ; then
    return
  fi
  install_kosli
  kosli_log_artifact "${KOSLI_STAGING_HOSTNAME}"
  kosli_log_artifact "${KOSLI_PROD_HOSTNAME}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_log_evidence()
{
  kosli pipeline artifact report evidence generic $(tagged_image_name) \
    --artifact-type docker \
    --description "server & client branch-coverage reports" \
    --evidence-type branch-coverage \
    --host "${1}" \
    --user-data "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_log_evidence()
{
  if ! on_ci ; then
    return
  fi
  install_kosli
  write_evidence_json
  kosli_log_evidence "${KOSLI_STAGING_HOSTNAME}"
  kosli_log_evidence "${KOSLI_PROD_HOSTNAME}"
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

# - - - - - - - - - - - - - - - - - - - - - - - -
kosli_log_deployment()
{
  docker pull $(tagged_image_name)
  install_kosli
  kosli pipeline deployment report $(tagged_image_name) \
    --artifact-type docker \
    --environment "${1}" \
    --host "${2}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}
