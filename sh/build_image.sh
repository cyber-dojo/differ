#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#source "${SH_DIR}/check_embedded_sha_env_var.sh"
#source "${SH_DIR}/echo_env_vars.sh"
#source "${SH_DIR}/tag_images_to_latest.sh"
source "${ROOT_DIR}/sh/lib.sh"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client}

    Options:
      server  - build the server image (local only)
      client  - build the client image (local and CI workflow)

EOF
}

build_image()
{
  local -r TYPE="${1}"

  case "${TYPE}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server')
      if [ -n "${CI:-}" ] ; then
        stderr "In CI workflow - use docker/build-push-action@v6 GitHub Action"
        exit 42
      fi
      ;;
    'client')
      ;;
    *)
      stderr "argument must be 'client' or 'server'"
      show_help
      exit 42
  esac

  exit_non_zero_unless_installed docker
  export $(echo_versioner_env_vars)
  containers_down
  #remove_old_images
  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" server
  if [ "${TYPE}" == 'client' ]; then
    docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" client
  fi

  #tag_images_to_latest "$@"
  #check_embedded_sha_env_var
  #echo_env_vars
}

build_image "$@"