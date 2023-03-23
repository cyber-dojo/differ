
on_ci_run_lint()
{
  if on_ci; then
    sudo gem install rubocop --no-document
    pwd
    rubocop .
  fi
}