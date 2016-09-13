#!/bin/sh
set -e

exit_if_not_installed() {
  hash ${1} 2> /dev/null
  if [ $? != 0 ]; then
    echo
    echo "${1} is not installed"
    exit 1
  fi
}

exit_if_not_installed 'docker'

OS=`uname -s`
if [ ${OS} == 'Darwin' ]; then
  exit_if_not_installed 'docker-machine'
  exit_if_not_installed 'docker-compose'
fi

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

cd ${MY_DIR}/sinatra && ./build-image.sh
cd ${MY_DIR}/client  && ./build-image.sh
cd ${MY_DIR}/server  && ./build-image.sh

docker images | grep cyberdojo/differ