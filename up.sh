#!/bin/bash

# Sticky bit must be set on /tmp otherwise
# Dir.mktmpdir(id,'/tmp') complains
# that it is world writable but not sticky.
chmod 1777 /tmp

rackup  \
  --env production  \
  --host 0.0.0.0    \
  --port 4567       \
  --server thin     \
  --warn            \
    config.ru
