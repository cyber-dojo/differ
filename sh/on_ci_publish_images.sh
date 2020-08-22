#!/bin/bash -Ee

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
  else
    echo 'on CI so publishing tagged images'
    local -r image_name="${CYBER_DOJO_DIFFER_IMAGE}"
    local -r image_tag="${CYBER_DOJO_DIFFER_TAG}"
    # DOCKER_USER, DOCKER_PASS are in ci context
    echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
    docker tag ${image_name}:${image_tag} ${image_name}:latest
    docker push ${image_name}:${image_tag}
    docker push ${image_name}:latest
    docker logout
  fi
}
