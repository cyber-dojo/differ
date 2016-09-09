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

cd sinatra && ./build-image.sh
if [ $? != 0 ]; then
  echo "FAILED TO BUILD cyberdojo/sinatra"
  exit 1
fi

cd ..
cd client && ./build-image.sh
if [ $? != 0 ]; then
  echo "FAILED TO BUILD differ_client"
  exit 1
fi

cd ..
cd server && ./build-image.sh
if [ $? != 0 ]; then
  echo "FAILED TO BUILD cyberdojo/differ"
  exit 1
fi

cd ..

ip=$(docker-machine ip default)
echo "${ip}:4568/diff"

docker-compose up

