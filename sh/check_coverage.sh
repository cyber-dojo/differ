#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${ROOT_DIR}/sh/lib.sh"

show_help()
{
    local -r my_name=check_coverage.sh
    cat <<- EOF

    Use: ${my_name} {client|server}

    Check test coverage (and other metrics) for tests run from inside the client or server container only

EOF
}

check_coverage()
{

  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server' | 'client')
      ;;
    *)
      stderr "$(echo "argument must be 'client' or 'server'")"
      show_help
      exit 42
  esac

  local -r TYPE="${1}" # eg server

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data against metrics.rb values and
  #   - print output showing individual metrics and their pass/fail status
  #   - return zero if all metrics pass, otherwise non-zero
  # Does not create any new files.

  local -r COVERAGE_CODE_TAB_NAME=app
  local -r COVERAGE_TEST_TAB_NAME=test

  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}"
  local -r HOST_METRICS_DIR="${ROOT_DIR}/test/${TYPE}/lib"

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME="${COVERAGE_CODE_TAB_NAME}" \
    --env COVERAGE_TEST_TAB_NAME="${COVERAGE_TEST_TAB_NAME}" \
    --rm \
    --volume "${HOST_REPORTS_DIR}":/reports/:ro \
    --volume "${HOST_METRICS_DIR}"/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
      sh -c \
        "ruby /app/check_test_results.rb \
          /reports/test.log \
          /reports/index.html \
          /reports/coverage.json" \
      | tee "${HOST_REPORTS_DIR}/metrics.log"

  local -r STATUS=${PIPESTATUS[0]}
  set -e

  echo "${TYPE} coverage status == ${STATUS}"
  echo
  return "${STATUS}"
}

check_coverage "$@"