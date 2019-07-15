
class ExternalGitter

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup(path)
    shell.assert_cd_exec(path, SETUP)
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

  def diff_0_1(path)
    shell.assert_cd_exec(path, DIFF)
  end

  private

  SETUP = [
    'git init --quiet',
    "git config user.name 'differ'",
    "git config user.email 'differ@cyber-dojo.org'"
  ].join(' && ')

  DIFF = [
    'git diff',
    '--unified=0',
    '--ignore-space-at-eol',
    '--find-copies-harder',
    '--indent-heuristic',
    '0',
    '1',
    '--'     # specifies to git that 0,1 are revisions and not filenames
  ].join(' ')

  def shell
    @externals.shell
  end

end
