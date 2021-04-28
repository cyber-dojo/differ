#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

readonly NAMESPACE="${1}" # beta|prod
readonly K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
readonly VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
source <(curl "${K8S_URL}/sh/deployment_functions.sh")
export $(curl "${VERSIONER_URL}/app/.env")
readonly CYBER_DOJO_DIFFER_TAG="${CIRCLE_SHA1:0:7}"
readonly YAML_VALUES_FILENAME="${ROOT_DIR}/.circleci/k8s-general-values.yml"


gcloud_init
helm_init

helm_upgrade_probe_yes_prometheus_yes \
   "${NAMESPACE}" \
   "differ" \
   "${CYBER_DOJO_DIFFER_IMAGE}" \
   "${CYBER_DOJO_DIFFER_TAG}" \
   "${CYBER_DOJO_DIFFER_PORT}" \
   "${YAML_VALUES_FILENAME}"

