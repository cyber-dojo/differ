#!/bin/sh

IMAGE_NAME=differ_client
docker build --tag ${IMAGE_NAME} .
if [ $? != 0 ]; then
  echo "FAILED TO BUILD ${IMAGE_NAME}"
  exit 1
fi
