#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - -
merkely_log_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

  # set CYBER_DOJO_DIFFER_IMAGE, CYBER_DOJO_DIFFER_TAG
  local -r VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
  export $(curl "${VERSIONER_URL}/app/.env")
  export CYBER_DOJO_DIFFER_TAG="${CIRCLE_SHA1:0:7}"

  # get image so fingerprint() works
  docker pull ${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}

  local -r MERKELY_CHANGE=merkely/change:latest
  local -r MERKELY_OWNER=cyber-dojo
  local -r MERKELY_PIPELINE=differ

	docker run \
    --env MERKELY_COMMAND=log_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_DESCRIPTION="Deployed to ${environment} in circleci pipeline" \
    --env MERKELY_ENVIRONMENT="${environment}" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_fingerprint()
{
  echo "docker://${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG}"
}

