
test_in_container()
{
  if [ "${1:-}" = 'client' ]; then
    run_tests \
      "${CYBER_DOJO_DIFFER_CLIENT_USER}" \
      "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}" \
      "${@:-}"
  fi

  if [ "${1:-}" = 'server' ]; then
    run_tests \
      "${CYBER_DOJO_DIFFER_SERVER_USER}" \
      "${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}" \
      "${@:-}"
  fi
}

run_tests()
{
  local -r USER="${1}"           # eg nobody
  local -r CONTAINER_NAME="${2}" # eg test_differ_server
  local -r TYPE="${3}"           # eg server

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  local -r COVERAGE_CODE_TAB_NAME=app
  local -r COVERAGE_TEST_TAB_NAME=test
  local -r TEST_LOG=test.log

  # CONTAINER_NAME is running with read-only:true and a non-root user (in docker-compose.yml). I want to
  # keep those settings in the docker-exec call below since that is how the microservice actually runs.
  # The run.sh is creating coverage files which I process on the host after it completes.
  # I've tried using a :rw volume mount (eg /reports) in docker-compose.yml and writing the
  # coverage files to /reports, so they automatically end up on the host. I cannot find a way that works
  # on both my M2 laptop, and in the CI workflow. So I am writing the coverage files to /tmp and
  # tar-piping them out.

  local -r CONTAINER_TMP_DIR=/tmp
  local -r CONTAINER_COVERAGE_DIR="${CONTAINER_TMP_DIR}/reports"

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/differ/test/lib/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${*:4}"
  local -r STATUS=$?
  set -e

  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}"
  rm -rf "${HOST_REPORTS_DIR}" &> /dev/null || true
  mkdir -p "${HOST_REPORTS_DIR}" &> /dev/null || true

  docker exec \
    "${CONTAINER_NAME}" \
    tar Ccf "${CONTAINER_COVERAGE_DIR}" - . \
        | tar Cxf "${HOST_REPORTS_DIR}" -

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
