#!/bin/sh

app_dir=${1}

image_name=cyberdojo/differ_base
docker build --build-arg app_dir=${app_dir} --tag ${image_name} .
if [ $? != 0 ]; then
  echo "FAILED TO BUILD ${image_name}"
  exit 1
fi
