#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo
  echo '  How to use test_wrapper.sh'
  echo
  echo '  1. running specific tests'
  echo '     $ ./run.sh <ID*>'
  echo
  echo '  2. running all the tests'
  echo '     $ ./run.sh'
  echo
  exit
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# collect trailing arguments to forward to tests

while (( "$#" )); do
  if [[ $1 == *.rb ]]; then
    TEST_FILES+=($1)
    shift
  else
    ARGS=($*)
    break
  fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run-the-tests

mkdir /usr/app/coverage
TEST_LOG=/usr/app/coverage/test.log
ruby -e "%w( ${TEST_FILES[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${ARGS[*]} | tee ${TEST_LOG}

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
ruby ${MY_DIR}/check_test_results.rb ${TEST_LOG}
EXIT_STATUS=$?
echo ${EXIT_STATUS}
exit ${EXIT_STATUS}