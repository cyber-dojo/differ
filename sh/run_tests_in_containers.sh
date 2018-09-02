#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME="${ROOT_DIR##*/}"

readonly DIFFER_COVERAGE_ROOT=/tmp/coverage

readonly SERVER_CID=`docker ps --all --quiet --filter "name=${MY_NAME}-server"`
readonly CLIENT_CID=`docker ps --all --quiet --filter "name=${MY_NAME}-client"`

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_server_tests()
{
  docker exec \
    --env DIFFER_COVERAGE_ROOT=${DIFFER_COVERAGE_ROOT} \
    "${SERVER_CID}" \
      sh -c "cd /app/test && ./run.sh ${*}"
  server_status=$?

  # You can't [docker cp] from a tmpfs, you have to tar-pipe out.
  docker exec "${SERVER_CID}" \
    tar Ccf \
      "$(dirname "${DIFFER_COVERAGE_ROOT}")" \
      - "$(basename "${DIFFER_COVERAGE_ROOT}")" \
        | tar Cxf "${ROOT_DIR}/server/" -

  echo "Coverage report copied to ${MY_NAME}/server/coverage/"
  cat "${ROOT_DIR}/server/coverage/done.txt"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

run_client_tests()
{
  docker exec \
    --env DIFFER_COVERAGE_ROOT=${DIFFER_COVERAGE_ROOT} \
    "${CLIENT_CID}" \
      sh -c "cd /app/test && ./run.sh ${*}"
  client_status=$?

  # You can't [docker cp] from a tmpfs, you have to tar-pipe out.
  docker exec "${CLIENT_CID}" \
    tar Ccf \
      "$(dirname "${DIFFER_COVERAGE_ROOT}")" \
      - "$(basename "${DIFFER_COVERAGE_ROOT}")" \
        | tar Cxf "${ROOT_DIR}/client/" -

  echo "Coverage report copied to ${MY_NAME}/client/coverage/"
  cat "${ROOT_DIR}/client/coverage/done.txt"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -

server_status=0
client_status=0

run_server_tests ${*}
run_client_tests ${*}

if [[ ( ${server_status} == 0 && ${client_status} == 0 ) ]];  then
  echo "------------------------------------------------------"
  echo "All passed"
  exit 0
else
  echo
  echo "server: cid = ${SERVER_CID}, status = ${server_status}"
  echo "client: cid = ${CLIENT_CID}, status = ${client_status}"
  echo
  exit 1
fi
