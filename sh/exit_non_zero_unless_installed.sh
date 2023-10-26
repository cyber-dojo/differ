
exit_non_zero_unless_installed()
{
  printf "Checking ${1} is installed..."
  if ! installed "${1}" ; then
    stderr 'ERROR: ${1} is not installed!'
    exit 42
  else
    echo It is
  fi
}

installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}