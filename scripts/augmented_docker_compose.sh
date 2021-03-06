
# cyberdojo/service-yaml image repo lives at
# https://github.com/cyber-dojo-tools/service-yaml

augmented_docker_compose()
{
  # Use project name with underscore separators
  # as they are easier to click-copy from a terminal.
  local -r project_name=cyber_dojo
  cd "${ROOT_DIR}" && cat "./docker-compose.yml" \
    | docker run --rm --interactive cyberdojo/service-yaml \
                       saver \
    | tee /tmp/augmented-docker-compose.differ.peek.yml \
    | docker-compose \
        --project-name cyber_dojo \
        --file -       \
        "$@"
}
