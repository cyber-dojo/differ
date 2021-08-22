#!/bin/bash -Eeu

deploy_to_namespace()
{
  local -r namespace="${1}" # beta|prod

  # get gcloud_init(), helm_init(), helm_upgrade_probe_yes_prometheus_yes()
  local -r K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
  source <(curl "${K8S_URL}/sh/deployment_functions.sh")

  # set CYBER_DOJO_DIFFER_IMAGE, CYBER_DOJO_DIFFER_PORT, CYBER_DOJO_DIFFER_TAG
  local -r VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  local -r CYBER_DOJO_DIFFER_TAG="${CIRCLE_SHA1:0:7}"

  local -r ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local -r YAML_VALUES_FILENAME="${ROOT_DIR}/.circleci/k8s-general-values.yml"

  gcloud_init
  helm_init

  helm_upgrade_probe_yes_prometheus_yes \
     "${namespace}" \
     "differ" \
     "${CYBER_DOJO_DIFFER_IMAGE}" \
     "${CYBER_DOJO_DIFFER_TAG}" \
     "${CYBER_DOJO_DIFFER_PORT}" \
     "${YAML_VALUES_FILENAME}"
}

