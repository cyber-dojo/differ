#!/bin/sh
set -e

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed"
  exit 1
fi

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

cd ${MY_DIR}/client  && ./build-image.sh
cd ${MY_DIR}/server  && ./build-image.sh

docker images | grep differ