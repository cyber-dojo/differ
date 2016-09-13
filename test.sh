#!/bin/sh

# I cant do [set -e] because if docker test-run fails
# I want the [docker cp] command to extract the coverage info

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
${MY_DIR}/build.sh
if [ $? != 0 ]; then
  echo
  echo "./build.sh FAILED"
  exit 1
fi

docker run --rm cyberdojo/differ sh -c 'cat /usr/app/Gemfile.lock'
docker run cyberdojo/differ sh -c "cd test/src && ./run.sh ${*}"
EXIT_STATUS=$?
CID=`docker ps --latest --quiet`
docker cp ${CID}:/tmp/coverage ${MY_DIR}
docker rm ${CID} > /dev/null
echo "coverage written to ${MY_DIR}/coverage"
cat ${MY_DIR}/coverage/done.txt
exit ${EXIT_STATUS}