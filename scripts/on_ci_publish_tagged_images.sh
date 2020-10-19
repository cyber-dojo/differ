#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  echo
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
  else
    echo 'on CI so publishing tagged images'
    local -r name="${CYBER_DOJO_DIFFER_IMAGE}"
    local -r tag="${CYBER_DOJO_DIFFER_TAG}"
    docker push ${name}:${tag}
    docker push ${name}:latest
  fi
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}
