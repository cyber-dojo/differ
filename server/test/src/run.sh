#!/bin/bash

# check already shelled inside docker container
if [ ! -f /.dockerenv ]; then
  echo "FAILED: run.sh is being executed outside of docker-container. See test.sh"
  exit 1
fi

# collect trailing arguments to forward to tests
if [[ $1 == *_test.rb ]]; then
  # shebang -> test_wrapper.sh -> test.sh -> run.sh
  FILES=($1)
  ARGS=()
else
  # test.sh -> run.sh
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
