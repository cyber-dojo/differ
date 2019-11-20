#!/bin/bash

export RUBYOPT='-W2'

rackup \
  --env production \
  --port 4568      \
  --warn           \
    config.ru
