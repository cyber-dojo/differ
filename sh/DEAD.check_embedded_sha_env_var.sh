
check_embedded_sha_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
  fi
}

echo_env_vars()
{
  echo "echo CYBER_DOJO_DIFFER_SHA=$(image_sha)"
  echo "echo CYBER_DOJO_DIFFER_TAG=$(image_tag)"
  echo
}

git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

image_name()
{
  echo "${CYBER_DOJO_DIFFER_IMAGE}"
}

image_tag()
{
  echo "${CYBER_DOJO_DIFFER_TAG}"
}

image_sha()
{
  echo "${CYBER_DOJO_DIFFER_SHA}"
}

sha_in_image()
{
  docker run --rm --entrypoint="" $(image_name):$(image_tag) sh -c 'echo -n ${SHA}'
}
