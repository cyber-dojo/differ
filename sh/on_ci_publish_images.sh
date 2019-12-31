#!/bin/bash -Ee

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm $(image_name):latest sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  local -r image="$(image_name)"
  local -r sha="$(image_sha)"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${image}:latest
  docker push ${image}:${sha:0:7}
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images
