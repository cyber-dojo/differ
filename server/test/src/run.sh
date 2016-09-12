#!/bin/bash

# already shelled inside docker container
# collect trailing arguments to forward to tests

if [[ $1 == *.rb ]]; then
  FILES=($1)
  ARGS=()
else
  FILES=(*_test.rb)
  ARGS=${*}
fi

# run the tests and collect coverage stats
COV_DIR=/tmp/coverage
mkdir ${COV_DIR}
TEST_LOG=${COV_DIR}/test.log
# (**) These requires turn off the effect of the shebangs in each individual file
ruby -e "%w( ${FILES[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${ARGS[@]} | tee ${TEST_LOG}
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
ruby ${MY_DIR}/../check_test_results.rb ${TEST_LOG} ${COV_DIR}/index.html
