#!/bin/sh
set -e

app_dir=${1:-/app}

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed"
  exit 1
fi

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

cd ${MY_DIR}/server  && ./build-image.sh ${app_dir}
cd ${MY_DIR}/client  && ./build-image.sh ${app_dir}

docker images | grep differ