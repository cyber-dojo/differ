
class ExternalGitter

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup(path)
    shell.assert_cd_exec(path,
      'git init --quiet',
      "git config user.name 'differ'",
      "git config user.email 'differ@cyber-dojo.org'"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def add_commit_tag(path, tag)
    shell.assert_cd_exec(path,
      'git add .',
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

  def space
    ' '
  end

end
