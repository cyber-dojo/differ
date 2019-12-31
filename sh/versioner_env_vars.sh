#!/bin/bash -Ee

cat_env_vars()
{
  docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'
}
