#!/bin/bash -Eeu

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DIFFER_CLIENT_PORT=9999
  echo CYBER_DOJO_DIFFER_CLIENT_USER=nobody
  echo CYBER_DOJO_DIFFER_SERVER_USER=nobody
}
