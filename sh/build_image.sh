#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#source "${SH_DIR}/check_embedded_sha_env_var.sh"
#source "${SH_DIR}/echo_env_vars.sh"
#source "${SH_DIR}/tag_images_to_latest.sh"
source "${ROOT_DIR}/sh/lib.sh"

build_image()
{
  local -r target="${1}"

  if [ -n "${CI:-}" ] && [ "${target}" == 'server' ] ; then
    echo In CI workflow - using server image built with the GitHub Action
  else
    echo Not in CI workflow - building image
    exit_non_zero_unless_installed docker
    containers_down
    export $(echo_versioner_env_vars)
    #remove_old_images
    #build_tagged_images "$@"
    docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" server
    if [ "${target}" != 'server' ]; then
      docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client
    fi

    #tag_images_to_latest "$@"
    #check_embedded_sha_env_var
    #echo_env_vars
  fi
}

#build_tagged_images()
#{
#  local -r target="${1}"
#  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" server
#  if [ "${target}" != 'server' ]; then
#    docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client
#  fi
#}

build_image "$@"