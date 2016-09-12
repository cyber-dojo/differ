#!/bin/sh

#docker run --rm --interactive --tty cyberdojo/differ sh

docker run --interactive --tty cyberdojo/differ sh
CID=`docker ps --latest --quiet`

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
docker cp ${CID}:/tmp/coverage ${MY_DIR}
docker rm ${CID} > /dev/null

