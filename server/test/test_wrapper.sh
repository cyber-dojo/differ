#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo
  echo '  How to use test_wrapper.sh'
  echo
  echo '  1. running specific tests in one folder'
  echo "     $ cd test/app_model"
  echo '     $ ./run.sh <ID*>'
  echo
  echo '  2. running all the tests in one folder'
  echo "     $ cd test/app_model"
  echo '     $ ./run.sh'
  echo
  echo '  3. running all the tests in all the folders'
  echo "     $ cd test"
  echo '     $ ./run.sh'
  echo
  exit
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# collect trailing arguments to forward to tests

while (( "$#" )); do
  if [[ $1 == *.rb ]]; then
    testFiles+=($1)
    shift
  else
    args=($*)
    break
  fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run-the-tests!

ruby -e "%w( ${testFiles[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${args[*]} 2>&1 | tee ${test_log}

