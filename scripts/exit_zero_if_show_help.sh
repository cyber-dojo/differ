
# - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_help()
{
  if show_help_arg "${1:-}"; then
    local -r my_name=build_test_publish.sh
    cat <<- EOF

    Use: ${my_name} [client|server] [ID...]
    Use: ${my_name} [-bo|--build-only]
    Use: ${my_name} [-do|--demo-only]

    Options:
       client  - run tests from inside the client only
       server  - run tests from inside the server only
       ID...   - run tests matching these identifiers only

EOF
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
show_help_arg()
{
  [ "${1:-}" == '--help' ] || [ "${1:-}" == '-h' ]
}
