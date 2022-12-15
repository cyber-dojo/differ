
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  local -r sha="$(cd "$(root_dir)" && git rev-parse HEAD)"
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
}

# - - - - - - - - - - - - - - - - - - - - - - - -
root_dir()
{
  # Functions in this file are called after sourcing (not including)
  # this file so root_dir() cannot use the path of this script.
  git rev-parse --show-toplevel
}