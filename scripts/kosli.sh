#!/usr/bin/env bash
set -Eeu

# ROOT_DIR must be set

MERKELY_CHANGE=merkely/change:latest
MERKELY_OWNER=cyber-dojo
MERKELY_PIPELINE=differ

# - - - - - - - - - - - - - - - - - - -
install_kosli()
{
  if ! hash kosli; then
    sudo apt-get update
    sudo apt-get install --yes wget
    pushd /tmp
    sudo wget https://github.com/kosli-dev/cli/releases/download/v0.1.8/kosli_0.1.8_linux_amd64.tar.gz
    sudo tar -xf kosli_0.1.8_linux_amd64.tar.gz
    sudo mv kosli /usr/local/bin
    popd
  fi
}

# - - - - - - - - - - - - - - - - - - -
kosli_fingerprint()
{
  echo "docker://${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_declare_pipeline()
{
  local -r hostname="${1}"
  install_kosli
  kosli pipeline declare \
    --api-token "${MERKELY_API_TOKEN}" \
    --description "Diff files from two traffic-lights" \
    --host "${hostname}" \
    --owner "${MERKELY_OWNER}" \
    --pipeline "${MERKELY_PIPELINE}" \
    --template artifact,branch-coverage \
    --visibility public
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_declare_pipeline()
{
  if ! on_ci ; then
    return
  fi
  kosli_declare_pipeline https://staging.app.kosli.com
  kosli_declare_pipeline https://app.kosli.com
}

# - - - - - - - - - - - - - - - - - - -
kosli_log_artifact()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_artifact \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_ARTIFACT_GIT_COMMIT=${CYBER_DOJO_DIFFER_SHA} \
    --env MERKELY_ARTIFACT_GIT_URL=https://github.com/${MERKELY_OWNER}/${MERKELY_PIPELINE}/commit/${CYBER_DOJO_DIFFER_SHA} \
    --env MERKELY_CI_BUILD_NUMBER=${CIRCLE_BUILD_NUM} \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_log_artifact()
{
  if ! on_ci ; then
    return
  fi
  kosli_log_artifact https://staging.app.kosli.com
  kosli_log_artifact https://app.kosli.com
}

# - - - - - - - - - - - - - - - - - - -
kosli_log_evidence()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_evidence \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(kosli_fingerprint) \
    --env MERKELY_EVIDENCE_TYPE=branch-coverage \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_DESCRIPTION="server & client branch-coverage reports" \
    --env MERKELY_USER_DATA="$(evidence_json_path)" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume "$(evidence_json_path):$(evidence_json_path)" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_log_evidence()
{
  if ! on_ci ; then
    return
  fi
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
on_ci()
{
  [ -n "${CI:-}" ]
}
