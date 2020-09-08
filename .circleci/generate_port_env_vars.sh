
generate_port_env_vars()
{
  echo '    env:'
  echo '      CYBER_DOJO_PROMETHEUS: "true"'
  for line in $(docker run --rm cyberdojo/versioner | grep PORT | tr ' ' '\n')
  do
    name="${line%=*}"
    port="${line#*=}"
    echo "      ${name}: \"${port}\""
  done
}
