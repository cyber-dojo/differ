#!/bin/sh

./build.sh

ip=$(docker-machine ip default)
echo "${ip}:4568/diff"

docker-compose up &


