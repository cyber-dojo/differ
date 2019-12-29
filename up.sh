#!/bin/bash
set -e

export RUBYOPT='-W2'

rackup \
  --env production \
  --port 4567      \
  --warn           \
    config.ru
