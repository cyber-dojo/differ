#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TYPE="${1}"     # server
readonly TEST_LOG="${2}"    # test.log
shift; shift

readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_ARGS=(${@})

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

export RUBYOPT='-W2'
export COVERAGE_ROOT="/reports/${TYPE}"
mkdir -p "${COVERAGE_ROOT}" &> /dev/null || true  # volume-mounted dir may already exist from previous run

set +e
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee "${COVERAGE_ROOT}/${TEST_LOG}"
STATUS=${PIPESTATUS[0]}
set -e

exit "${STATUS}"
