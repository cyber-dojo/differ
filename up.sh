#!/bin/bash

export RUBYOPT='-W2'

rackup  \
  --env production  \
  --server thin     \
  --warn            \
    config.ru
