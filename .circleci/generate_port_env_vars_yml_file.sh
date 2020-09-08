#/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

generate_port_env_vars_yaml_file()
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

generate_port_env_vars_yaml_file > "${MY_DIR}/env-var-values.yml"
