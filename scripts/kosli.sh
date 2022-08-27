#!/usr/bin/env bash
set -Eeu

# TODO: delete
# MERKELY_CHANGE=merkely/change:latest
# MERKELY_OWNER=cyber-dojo
# MERKELY_PIPELINE=differ
# ROOT_DIR must be set

export KOSLI_OWNER=cyber-dojo
export KOSLI_API_TOKEN=${MERKELY_API_TOKEN}
export KOSLI_PIPELINE=differ

# - - - - - - - - - - - - - - - - - - -
install_kosli()
{
  # brew is not installed on Ubuntu 20.04, so can't directly do
  # brew install kosli-dev/tap/kosli
  if ! hash kosli; then
    sudo apt-get update
    sudo apt-get install --yes wget
    pushd /tmp
    local -r version=0.1.9
    sudo wget https://github.com/kosli-dev/cli/releases/download/v${version}/kosli_${version}_linux_amd64.tar.gz
    sudo tar -xf kosli_${version}_linux_amd64.tar.gz
    sudo mv kosli /usr/local/bin
    popd
  fi
}

# - - - - - - - - - - - - - - - - - - -
tagged_image_name()
{
  VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
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
  kosli_declare_pipeline https://staging.app.kosli.com
  kosli_declare_pipeline https://app.kosli.com
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
  kosli_log_artifact https://staging.app.kosli.com
  kosli_log_artifact https://app.kosli.com
}

# - - - - - - - - - - - - - - - - - - -
# kosli_log_evidence()
# {
#   local -r hostname="${1}"
#
#   docker run \
#     --env MERKELY_COMMAND=log_evidence \
#     --env MERKELY_OWNER=${MERKELY_OWNER} \
#     --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
#     --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
#     --env MERKELY_EVIDENCE_TYPE=branch-coverage \
#     --env MERKELY_IS_COMPLIANT=TRUE \
#     --env MERKELY_DESCRIPTION="server & client branch-coverage reports" \
#     --env MERKELY_USER_DATA="$(evidence_json_path)" \
#     --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
#     --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
#     --env MERKELY_HOST="${hostname}" \
#     --rm \
#     --volume "$(evidence_json_path):$(evidence_json_path)" \
#     --volume /var/run/docker.sock:/var/run/docker.sock \
#       ${MERKELY_CHANGE}
# }

# - - - - - - - - - - - - - - - - - - -
kosli_log_evidence()
{
  kosli artifact report evidence generic $(tagged_image_name) \
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
  kosli_log_evidence https://staging.app.kosli.com
  kosli_log_evidence https://app.kosli.com
}

# - - - - - - - - - - - - - - - - - - -
write_evidence_json()
{
  echo '{ "server": ' > "$(evidence_json_path)"
  cat "${ROOT_DIR}/test/reports/coverage.json" >> "$(evidence_json_path)"
  echo ', "client": ' >> "$(evidence_json_path)"
  cat "${ROOT_DIR}/client/test/reports/coverage.json" >> "$(evidence_json_path)"
  echo '}' >> "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
evidence_json_path()
{
  echo "${ROOT_DIR}/test/reports/evidence.json"
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
