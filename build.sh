#!/bin/sh

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed"
  exit 1
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
app_dir=${1}
client_port=${2}
server_port=${3}

cd ${my_dir}/base    && ./build-image.sh ${app_dir}
cd ${my_dir}/client  && ./build-image.sh ${app_dir} ${client_port}
cd ${my_dir}/server  && ./build-image.sh ${app_dir} ${server_port}

docker images | grep differ