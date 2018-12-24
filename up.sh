#!/bin/bash

# [1] avoids warnings such as
#   Bundler will use `/tmp/bundler/home/unknown' as your home directory temporarily
# important for tests asserting container log contents at startup.

HOME=/tmp `#[1]`     \
  bundle exec rackup \
    --warn           \
    --host 0.0.0.0   \
    --port 4567      \
    --server thin    \
    --env production \
      config.ru
