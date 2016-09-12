#!/bin/sh

./build.sh
if [ $? != 0 ]; then
  exit 1
fi

ip=$(docker-machine ip default)
echo "${ip}:4568/diff"

docker images --quiet --filter=dangling=true | xargs docker rmi

docker-compose up &


