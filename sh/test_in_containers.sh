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
  local -r reports_dir_name=reports
  local -r tmp_dir=/tmp
  local -r coverage_root=/${tmp_dir}/${reports_dir_name}
  local -r test_dir="${SH_DIR}/../test/${type}"
  local -r reports_dir=${test_dir}/${reports_dir_name}
  local -r test_log=test.log
  local -r container_name="test-differ-${type}" # eg test-differ-server
  local -r coverage_code_tab_name=app
  local -r coverage_test_tab_name=test

  echo
  echo '=================================='
  echo "Running ${type} tests"
  echo '=================================='

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --user "${user}" \
    "${container_name}" \
      sh -c "/differ/test/lib/run.sh ${coverage_root} ${test_log} ${*:3}"
  set -e

  # You can't [docker cp] from a tmpfs, so tar-piping coverage out
  docker exec \
    "${container_name}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${test_dir}/" -

  set +e
  docker run \
    --env COVERAGE_CODE_TAB_NAME=${coverage_code_tab_name} \
    --env COVERAGE_TEST_TAB_NAME=${coverage_test_tab_name} \
    --rm \
    --volume ${reports_dir}/${test_log}:${tmp_dir}/${test_log}:ro \
    --volume ${reports_dir}/index.html:${tmp_dir}/index.html:ro \
    --volume ${test_dir}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
    sh -c "ruby /app/check_test_results.rb ${tmp_dir}/${test_log} ${tmp_dir}/index.html" \
      | tee -a ${reports_dir}/${test_log}
  local -r status=${PIPESTATUS[0]}
  set -e

  local -r coverage_path="${reports_dir}/index.html"
  echo "${type} test coverage at ${coverage_path}"
  echo "${type} test status == ${status}"
  if [ "${status}" != '0' ]; then
    docker logs "${container_name}"
  fi
  return ${status}
}
