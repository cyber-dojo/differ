#!/bin/bash -Ee

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_DIFFER_CLIENT_PORT=4568
}
