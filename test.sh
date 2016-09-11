#!/bin/sh
docker images --quiet --filter=dangling=true | xargs docker rmi
./build.sh
docker run --cidfile=${CIDFILE} cyberdojo/differ sh -c "cd test/lib && ./run.sh ${1}"
CID=`docker ps --latest --quiet`
docker rm ${CID} > /dev/null
