#!/bin/bash -Ee

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
  else
    echo 'on CI so publishing tagged images'
    local -r name="${CYBER_DOJO_DIFFER_IMAGE}"
    local -r tag="${CYBER_DOJO_DIFFER_TAG}"
    # DOCKER_USER, DOCKER_PASS are in ci context
    echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
    docker push ${name}:${tag}
    docker push ${name}:latest
    docker logout
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}
