#!/bin/sh

exit_if_not_installed() {
  hash ${1} 2> /dev/null
  if [ $? != 0 ]; then
    echo
    echo "${1} is not installed"
    exit 1
  fi
}

exit_if_not_installed 'docker'
exit_if_not_installed 'docker-machine'
exit_if_not_installed 'docker-compose'

cd client && ./build-image.sh
cd ..
cd server && ./build-image.sh
cd ..
docker-compose up
