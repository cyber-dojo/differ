
class ExternalGitter

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup(path, user_name, user_email)
    shell.assert_cd_exec(path,
      'git init --quiet',
      "git config user.name #{quoted(user_name)}",
      "git config user.email #{quoted(user_email)}"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def add(path, filename)
    shell.assert_cd_exec(path, "git add #{quoted(filename)}")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def rm(path, filename)
    shell.assert_cd_exec(path, "git rm #{quoted(filename)}")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def commit(path, tag)
    shell.assert_cd_exec(path,
      "git commit --allow-empty --all --message #{tag} --quiet",
      "git tag #{tag} HEAD"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff(path, n, m)
    options = [
      '--unified=0',
      '--ignore-space-at-eol',
      '--find-copies-harder',
      '--indent-heuristic',
      "#{n}",
      "#{m}",
      '--'     # specifies to git that n,m are revisions and not filenames
    ].join(space)
    shell.assert_cd_exec(path, "git diff #{options}")
  end

  private

  def shell
    @externals.shell
  end

  def quoted(s)
    "'" + s + "'"
  end

  def space
    ' '
  end

end
