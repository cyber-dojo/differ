#!/bin/sh
set -e
docker images --quiet --filter=dangling=true | xargs docker rmi

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
cd ${MY_DIR} && ./build.sh
docker run --rm cyberdojo/differ sh -c 'cat /usr/app/Gemfile.lock'
docker run cyberdojo/differ sh -c "cd test/src && ./run.sh ${1}"
CID=`docker ps --latest --quiet`
docker cp ${CID}:/usr/app/coverage ${MY_DIR}
docker rm ${CID} > /dev/null
