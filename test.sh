#!/bin/sh

# Don't do [set -e] because if [docker run ... && ./run.sh] fails
# I want the [docker cp] command to extract the coverage info

# Use 1: ./test.sh
#   Load and run all tests.
# Use 2: ./test.sh 347
#   Load all tests and run those whose hex-id includes 347
#   Use the test file's hex-id prefix to run *all* the tests in that file
#   Use the tests individual hex-id to run just that one test

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
${my_dir}/build.sh
if [ $? != 0 ]; then
  echo
  echo "./build.sh FAILED"
  exit 1
fi

docker run --rm cyberdojo/differ sh -c 'cat Gemfile.lock'
docker run cyberdojo/differ sh -c "cd test && ./run.sh ${*}"
status=$?
cid=`docker ps --latest --quiet`
docker cp ${cid}:/tmp/coverage ${my_dir}
docker rm ${cid} > /dev/null
echo "coverage written to ${my_dir}/coverage"
cat ${my_dir}/coverage/done.txt
exit ${status}