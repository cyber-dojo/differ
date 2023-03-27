
on_ci_run_lint()
{
  if on_ci; then
    sudo gem install rubocop --no-document
    mkdir -p /tmp/evidence/lint
    cp "$(root_dir)/.rubocop.yml" /tmp/evidence/lint
    set +e
    rubocop . | tee /tmp/evidence/lint/rubocop.log
    local -r STATUS=$?
    set -e

    if [ "${STATUS}" == "0" ]; then
      export KOSLI_LINT_COMPLIANT="true"
    else
      export KOSLI_LINT_COMPLIANT="false"
    fi
  fi
}

# - - - - - - - - - - - - - - - - - - -
root_dir()
{
  # Functions in this file are called after sourcing (not including)
  # this file so root_dir() cannot use the path of this script.
  git rev-parse --show-toplevel
}
