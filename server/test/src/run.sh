#!/bin/bash

# check already shelled inside docker container
if [ ! -f /.dockerenv ]; then
  echo 'FAILED: run.sh is being executed outside of docker-container.'
  echo 'See test.sh which first calls build.sh'
  exit 1
fi

# Use 1: ./test.sh
#    -> run.sh
#   load and run all tests.
# Use 2: ./test.sh 347
#   -> run.sh ARG=347
#   load all tests and run those whose hex-id matches 347
# Use 3: cd server/test/src && ./line_splitter_test.rb
#   -> run.sh ARG=line_splitter_test.rb
#   (via test_wrapper.sh -> test.sh)
#   load one test-file and run all its tests

if [[ $1 == *_test.rb ]]; then
  # Use 3
  FILES=($1)
  ARGS=()
else
  # Uses 1 & 2
  FILES=(*_test.rb)
  ARGS=(${*})
fi

# run the tests with coverage
COV_DIR=/tmp/coverage
mkdir ${COV_DIR}
TEST_LOG=${COV_DIR}/test.log
# turn off the effect of the shebangs in each individual file
ruby -e "%w( ${FILES[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${ARGS[@]} | tee ${TEST_LOG}
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
# collect coverage stats
ruby ${MY_DIR}/../check_test_results.rb ${TEST_LOG} ${COV_DIR}/index.html > ${COV_DIR}/done.txt
