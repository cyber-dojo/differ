#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client} [ID...]

    Options:
      client  - run tests inside the client container only
      server  - run tests inside the server container only
      ID...   - run tests matching these identifiers only

    Example:
      ${MY_NAME} server 198
      ...
      Finished in 0.012960s, 308.6469 runs/s, 3395.1162 assertions/s.
      4 runs, 44 assertions, 0 failures, 0 errors, 0 skips
      ...
      Slowest tests are...
      0.0084 - 198603:prober_test.rb:24:ready
      0.0000 - 198191:prober_test.rb:12:sha
      0.0000 - 198604:prober_test.rb:30:|when saver http-proxy is not ready |then ready? is false
      0.0000 - 198601:prober_test.rb:20:alive

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server')
      # shellcheck disable=SC2046
      export $(echo_env_vars)
      export CONTAINER_NAME="${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}"
      export USER="${CYBER_DOJO_DIFFER_SERVER_USER}"
      ;;
    'client')
      # shellcheck disable=SC2046
      export $(echo_env_vars)
      export CONTAINER_NAME="${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}"
      export USER="${CYBER_DOJO_DIFFER_CLIENT_USER}"
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit_non_zero
      ;;
    *)
      show_help
      stderr "first argument is '${1:-}' - must be 'client' or 'server'"
      exit_non_zero
  esac
}

run_tests()
{
  check_args "$@"

  local -r TYPE="${1}"           # {server|client}
  local -r TEST_LOG=test.log
  local -r CONTAINER_COVERAGE_DIR="/tmp/reports"
  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}"

  exit_non_zero_unless_installed docker
  export SERVICE_NAME="${1}"
  # Don't do a build here, because in CI workflow, server image is built with GitHub Action
  docker --log-level=ERROR compose --progress=plain up --no-build --wait --wait-timeout=10 "${SERVICE_NAME}"
  echo_warnings "${TYPE}"
  copy_in_saver_test_data

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  # CONTAINER_NAME is running with read-only:true and a non-root user (in docker-compose.yml). I want to
  # keep those settings in the docker-exec call below since that is how I want the microservice to run.
  # The [docker exec run.sh] is creating coverage files which I process on the host after it completes.
  # I've tried using an :rw volume mount (eg /reports) in docker-compose.yml and writing the
  # coverage files to /reports, so they automatically end up on the host. I cannot find a way that works
  # on both my Mac M-laptop, and in the CI workflow. So I am writing the coverage files to /tmp and
  # tar-piping them out.

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=code \
    --env COVERAGE_TEST_TAB_NAME=test \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/differ/test/lib/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${*:2}"
  local -r STATUS=$?
  set -e

  rm -rf "${HOST_REPORTS_DIR}" &> /dev/null || true
  mkdir -p "${HOST_REPORTS_DIR}" &> /dev/null || true

  docker exec --user "${USER}" "${CONTAINER_NAME}" tar Ccf "${CONTAINER_COVERAGE_DIR}" - . \
    | tar Cxf "${HOST_REPORTS_DIR}" -

  # Check we generated the expected files.
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/${TEST_LOG}"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/index.html"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/test_metrics.json"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"

  echo "${TYPE} test branch-coverage report is at:"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo
  echo "${TYPE} test status == ${STATUS}"
  echo

  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi

  return ${STATUS}
}

run_tests "$@"