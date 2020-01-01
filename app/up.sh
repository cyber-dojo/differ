#!/bin/bash -Eeu

export RUBYOPT='-W2'

rackup \
  --env production \
  --port 4567      \
  --warn           \
    /app/config.ru
