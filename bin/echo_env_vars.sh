
echo_env_vars()
{
  # Set env-vars for this repos differ service
  if [[ ! -v COMMIT_SHA ]] ; then
    local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
    echo COMMIT_SHA="${sha}"  # --build-arg ...
  fi

  # Setup port env-vars in .env file using versioner
  {
    echo "# This file is generated in bin/lib.sh echo_env_vars()"
    echo "CYBER_DOJO_DIFFER_CLIENT_PORT=9999"
    docker run --rm cyberdojo/versioner 2> /dev/null | grep PORT
  } > "${ROOT_DIR}/.env"

  # From versioner
  docker run --rm cyberdojo/versioner 2> /dev/null

  echo CYBER_DOJO_DIFFER_SHA="${sha}"
  echo CYBER_DOJO_DIFFER_TAG="${sha:0:7}"
  #
  echo CYBER_DOJO_DIFFER_CLIENT_IMAGE=cyberdojo/differ-client
  echo CYBER_DOJO_DIFFER_CLIENT_PORT=9999
  #
  echo CYBER_DOJO_DIFFER_CLIENT_USER=nobody
  echo CYBER_DOJO_DIFFER_SERVER_USER=nobody
  #
  echo CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME=test_differ_client
  echo CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME=test_differ_server
  #
  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_DIFFER_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/differ"
  
  # Overrides for local development
  #echo CYBER_DOJO_SAVER_SHA=d80c6e4f9d17b41da878fa69315de7298e059350
  #echo CYBER_DOJO_SAVER_TAG=d80c6e4
}
