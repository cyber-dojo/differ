
# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_container()
{
  if [ "${1:-}" = 'client' ]; then
    run_tests \
      "${CYBER_DOJO_DIFFER_CLIENT_USER}" \
      "${CYBER_DOJO_DIFFER_CLIENT_CONTAINER_NAME}" \
      client "${@:-}"
  fi

  if [ "${1:-}" = 'server' ]; then
    run_tests \
      "${CYBER_DOJO_DIFFER_SERVER_USER}" \
      "${CYBER_DOJO_DIFFER_SERVER_CONTAINER_NAME}" \
      "${@:-}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
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

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/differ/test/lib/run.sh ${TYPE} ${TEST_LOG} ${*:4}"
  local -r STATUS=$?
  set -e

  echo "${TYPE} test status == ${STATUS}"
  echo
  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi
  return ${STATUS}
}
