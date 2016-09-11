#!/bin/sh
docker images --quiet --filter=dangling=true | xargs docker rmi
./build.sh
CIDFILE=`mktemp -t cyber-dojo.cid.XXXXXX`
rm ${CIDFILE}
docker run --cidfile=${CIDFILE} cyberdojo/differ sh -c "cd test/lib && ./run.sh ${1}"
CID=`cat ${CIDFILE}`
docker rm ${CID} > /dev/null

