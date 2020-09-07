
generate_port_env_vars()
{
  echo
  echo 'containers:'
  echo '  - name: differ'
  echo '    env:'
  for line in $(docker run --rm cyberdojo/versioner | grep PORT | tr ' ' '\n')
  do
    name="${line%=*}"
    port="${line#*=}"
    echo "      ${name}: \"${port}\""
  done
}
