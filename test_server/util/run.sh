#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_ARGS=(${*})
readonly TEST_LOG=${COVERAGE_ROOT}/test.log

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

export RUBYOPT='-W2'
mkdir -p ${COVERAGE_ROOT}

set +e

ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} \
  2>&1 | tee ${TEST_LOG}

ruby ${MY_DIR}/check_test_results.rb \
  ${TEST_LOG} \
  ${COVERAGE_ROOT}/index.html \
    > ${COVERAGE_ROOT}/done.txt
