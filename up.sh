#!/bin/bash

# [1] avoids warnings such as
#   Bundler will use `/tmp/bundler/home/unknown' as your home directory temporarily
# important for tests asserting container log contents at startup.

HOME=/tmp `#[1]`     \
  bundle exec rackup \
    --env production \
    --host 0.0.0.0   \
    --port 4567      \
    --server thin    \
    --warn           \
      config.ru
