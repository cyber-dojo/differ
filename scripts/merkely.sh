#!/bin/bash -Eeu

MERKELY_CHANGE=merkely/change:latest
MERKELY_OWNER=cyber-dojo
MERKELY_PIPELINE=differ

# - - - - - - - - - - - - - - - - - - -
merkely_declare_pipeline()
{
  if ! on_ci ; then
    return
  fi
	docker run \
		--env MERKELY_COMMAND=declare_pipeline \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
		--env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
		--rm \
		--volume ${ROOT_DIR}/Merkelypipe.json:/data/Merkelypipe.json \
		${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_artifact()
{
  if ! on_ci ; then
    return
  fi
	docker run \
    --env MERKELY_COMMAND=log_artifact \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=docker://${CYBER_DOJO_DIFFER_IMAGE}:${CYBER_DOJO_DIFFER_TAG} \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_ARTIFACT_GIT_COMMIT=${CYBER_DOJO_DIFFER_SHA} \
    --env MERKELY_ARTIFACT_GIT_URL=https://github.com/cyber-dojo/differ/commit/${CYBER_DOJO_DIFFER_SHA} \
    --env MERKELY_CI_BUILD_NUMBER=${CIRCLE_BUILD_NUM} \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --rm \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    ${MERKELY_CHANGE}
}