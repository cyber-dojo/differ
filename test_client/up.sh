#!/bin/bash -Eeu

export RUBYOPT='-W2'

rackup \
  --env production \
  --port ${PORT}   \
  --warn           \
    config.ru
