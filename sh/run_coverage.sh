#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_coverage()
{
  local -r TYPE="${1}" # eg server

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data against metrics.rb values and
  #   - print output showing individual metrics and their pass/fail status
  #   - return zero if all metrics pass, otherwise non-zero
  # Does not create any new files

  local -r COVERAGE_CODE_TAB_NAME=app
  local -r COVERAGE_TEST_TAB_NAME=test

  if [ "${TYPE}" == 'server' ]; then
    local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/server"
    local -r HOST_METRICS_DIR="${ROOT_DIR}/test/lib"
  else
    local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/client"
    local -r HOST_METRICS_DIR="${ROOT_DIR}/client/test/lib"
  fi

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME="${COVERAGE_CODE_TAB_NAME}" \
    --env COVERAGE_TEST_TAB_NAME="${COVERAGE_TEST_TAB_NAME}" \
    --rm \
    --volume ${HOST_REPORTS_DIR}:/reports/:ro \
    --volume ${HOST_METRICS_DIR}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
      sh -c \
        "ruby /app/check_test_results.rb \
          /reports/test.log \
          /reports/index.html \
          /reports/coverage.json" \
    | tee "${HOST_REPORTS_DIR}/metrics.log"

  local -r STATUS=${PIPESTATUS[0]}
  set -e

  echo "${TYPE} test branch-coverage report is at:"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo "${TYPE} coverage status == ${STATUS}"
  echo
  return ${STATUS}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_coverage "$@"
fi