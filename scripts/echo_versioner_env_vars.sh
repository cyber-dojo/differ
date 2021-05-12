
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  local -r sha="$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
  docker run --rm cyberdojo/versioner
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

  # Forthcoming deployments
  #echo CYBER_DOJO_SAVER_SHA=2ae8e51362c5ad215b86d6065b0f850fae667ea8
  #echo CYBER_DOJO_SAVER_TAG=2ae8e51
  #echo CYBER_DOJO_MODEL_SHA=3fb3f3764cab60078fe5e4577a7a94b786cef308
  #echo CYBER_DOJO_MODEL_TAG=3fb3f37
}
