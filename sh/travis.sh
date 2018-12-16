#!/bin/bash
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  ./pipe_build_up_test.sh
  curl -O https://raw.githubusercontent.com/cyber-dojo/cyber-dojo/master/shared/push_and_trigger.sh
  chmod +x push_and_trigger.sh
  ./push_and_trigger.sh cyber-dojo/web
fi
