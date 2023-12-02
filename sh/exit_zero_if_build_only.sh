
# - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_build_only()
{
  if build_only_arg "${1:-}" ; then
    echo
    echo_env_vars
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
build_only_arg()
{
  [ "${1:-}" = '--build-only' ] || [ "${1:-}" = '-bo' ]
}
