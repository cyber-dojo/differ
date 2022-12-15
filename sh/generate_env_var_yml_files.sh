
# - - - - - - - - - - - - - - - - - - - - - -
echo_docker_compose_yml_port_env_vars()
{
  for line in $(docker run --rm cyberdojo/versioner | grep PORT | tr ' ' '\n')
  do
    name="${line%=*}"
    port="${line#*=}"
    echo "${name}=${port}"
  done
}

# - - - - - - - - - - - - - - - - - - - - - -
generate_env_var_yml_files()
{
  echo "Generating env-var .yml files"
  echo_docker_compose_yml_port_env_vars > "${ROOT_DIR}/.env"
}
