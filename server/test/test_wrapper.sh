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
    testFiles+=($1)
    shift
  else
    args=($*)
    break
  fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run-the-tests!

mkdir /usr/app/coverage
ruby -e "%w( ${testFiles[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${args[*]} | tee /usr/app/coverage/test.log

