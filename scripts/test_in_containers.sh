#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_containers()
{
  if on_ci; then
    docker pull cyberdojo/check-test-results:latest
  fi
  if [ "${1:-}" == 'client' ]; then
    shift
    run_client_tests "${@:-}"
  elif [ "${1:-}" == 'server' ]; then
    shift
    run_server_tests "${@:-}"
  else
    run_server_tests "${@:-}"
    run_client_tests "${@:-}"
  fi
  echo All passed
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  run_tests "${CYBER_DOJO_DIFFER_CLIENT_USER}" client "${@:-}";
}

run_server_tests()
{
  run_tests "${CYBER_DOJO_DIFFER_SERVER_USER}" server "${@:-}";
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r user="${1}" # eg nobody
  local -r type="${2}" # eg client|server
  local -r container_name="test-differ-${type}" # eg test-differ-server

  local -r coverage_code_tab_name=app
  local -r coverage_test_tab_name=test
  local -r container_tmp_dir=/tmp
  local -r container_coverage_dir=/${container_tmp_dir}/reports
  local -r test_log=test.log

  echo
  echo '=================================='
  echo "Running ${type} tests"
  echo '=================================='

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run tests (with coverage) inside the container.

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --user "${user}" \
    "${container_name}" \
      sh -c "/differ/test/lib/run.sh ${container_coverage_dir} ${test_log} ${*:3}"
  set -e

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-run results and coverage data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  if [ "${type}" == 'server' ]; then
    local -r host_test_dir="${SH_DIR}/../test"
  else
    local -r host_test_dir="${SH_DIR}/../client/test"
  fi

  docker exec \
    "${container_name}" \
    tar Ccf \
      "$(dirname "${container_coverage_dir}")" \
      - "$(basename "${container_coverage_dir}")" \
        | tar Cxf "${host_test_dir}/" -

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data.

  local -r host_reports_dir=${host_test_dir}/reports
  mkdir -p "${host_reports_dir}"

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --rm \
    --volume ${host_reports_dir}/${test_log}:${container_tmp_dir}/${test_log}:ro \
    --volume ${host_reports_dir}/index.html:${container_tmp_dir}/index.html:ro \
    --volume ${host_reports_dir}/coverage.json:${container_tmp_dir}/coverage.json:ro \
    --volume ${host_test_dir}/lib/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
    sh -c "ruby /app/check_test_results.rb ${container_tmp_dir}/${test_log} ${container_tmp_dir}/index.html ${container_tmp_dir}/coverage.json" \
      | tee -a ${host_reports_dir}/${test_log}
  local -r status=${PIPESTATUS[0]}
  set -e

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Tell caller where the results are...

  echo "${type} test coverage at ${host_reports_dir}/index.html"
  echo "${type} test status == ${status}"
  if [ "${status}" != '0' ]; then
    docker logs "${container_name}"
  fi
  return ${status}
}
