#!/usr/bin/env bash
set -Eu

IMAGE_NAME="${1}"        # eg cyberdojo/differ:6d650d5
KOSLI_HOST="${2}"        # eg https://app.kosli.com
KOSLI_API_TOKEN="${3}"   # eg 7654y432er7132rwaefdgzfvdc (fake)
KOSLI_ORG="${4}"         # eg cyber-dojo
KOSLI_ENVIRONMENT="${5}" # eg aws-prod

image_deployed()
{
    local -r snapshot_json_filename=snapshot.json

    # Use Kosli CLI to get info on what artifacts are currently running
    # (docs/snapshot.json contains an example json file)
    kosli get snapshot "${KOSLI_ENVIRONMENT}" \
      --host="${KOSLI_HOST}" \
      --api-token="${KOSLI_API_TOKEN}" \
      --org="${KOSLI_ORG}" \
      --output=json \
        > "${snapshot_json_filename}"

    # Process info, one artifact at a time
    local -r artifacts_length=$(jq '.artifacts | length' ${snapshot_json_filename})
    for i in $(seq 0 $(( artifacts_length - 1 )));
    do
        annotation_type=$(jq -r ".artifacts[$i].annotation.type" ${snapshot_json_filename})
        if [ "${annotation_type}" != "exited" ]; then
          fingerprint=$(jq -r ".artifacts[$i].fingerprint" ${snapshot_json_filename})
          if [ "${fingerprint}" == "${FINGERPRINT}" ]; then
            return 0 # true
          fi
       fi
    done
    return 1 # false
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker pull "${IMAGE_NAME}"
FINGERPRINT=$(kosli fingerprint "${IMAGE_NAME}" --artifact-type=docker)

MAX_WAIT_TIME=$((8 * 60))  # max time to wait for image to be deployed
SLEEP_TIME=15              # wait time between deployment checks
MAX_ATTEMPTS=$(( MAX_WAIT_TIME / SLEEP_TIME ))
ATTEMPTS=1

until image_deployed
do
  sleep 10
  [[ ${ATTEMPTS} -eq ${MAX_ATTEMPTS} ]] && echo "Failed!" && exit 1
  ((ATTEMPTS++))
  echo "Waiting for deployment of Artifact ${IMAGE_NAME} to Environment ${KOSLI_ENVIRONMENT}"
  echo "Attempt #${ATTEMPTS}"
done
exit 0
