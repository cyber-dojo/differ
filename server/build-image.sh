#!/bin/sh

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
app_dir=${1}
port=${2}

# there is no envsubst in Docker-Toolbox
cat ${my_dir}/Dockerfile.PORT | sed "s/PORT/${port}/" > ${my_dir}/Dockerfile
cat ${my_dir}/Procfile.PORT   | sed "s/PORT/${port}/" > ${my_dir}/Procfile

image_name=cyberdojo/differ

docker build --build-arg app_dir=${app_dir} --tag ${image_name} ${my_dir}
