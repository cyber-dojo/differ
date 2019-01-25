#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME=differ

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_tests()
{
  local COVERAGE_ROOT=/tmp/coverage
  local user="${1}"
  local dir="test_${2}"
  local cid=$(docker ps --all --quiet --filter "name=test-${MY_NAME}-${2}")
  docker exec \
    --user "${user}" \
    --env COVERAGE_ROOT=${COVERAGE_ROOT} \
    "${cid}" \
      sh -c "/app/test/util/run.sh ${@:4}"

  local status=$?

  # You can't [docker cp] from a tmpfs, you have to tar-pipe out.
  docker exec "${cid}" \
    tar Ccf \
      "$(dirname "${COVERAGE_ROOT}")" \
      - "$(basename "${COVERAGE_ROOT}")" \
        | tar Cxf "${ROOT_DIR}/${dir}/" -

  echo "Coverage report copied to ${dir}/coverage/"
  cat "${ROOT_DIR}/${dir}/coverage/done.txt"
  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

declare server_status=0
declare client_status=0

run_server_tests()
{
  run_tests "nobody" "server" "${*}"
  server_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  run_tests "nobody" "client" "${*}"
  client_status=$?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = "server" ]; then
  shift
  run_server_tests "$@"
elif [ "$1" = "client" ]; then
  shift
  run_client_tests "$@"
else
  run_server_tests "$@"
  run_client_tests "$@"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ ( ${server_status} == 0 && ${client_status} == 0 ) ]];  then
  echo "------------------------------------------------------"
  echo "All passed"
  exit 0
else
  echo
  echo "test-${MY_NAME}-server: status = ${server_status}"
  echo "test-${MY_NAME}-client: status = ${client_status}"
  echo
  exit 1
fi
