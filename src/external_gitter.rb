# frozen_string_literal: true

class ExternalGitter

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup(path)
    shell.assert_cd_exec(path, SETUP)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def add_commit_tag_0(path)
    shell.assert_cd_exec(path, ADD_COMMIT_TAG_0)
  end

  def add_commit_tag_1(path)
    shell.assert_cd_exec(path, ADD_COMMIT_TAG_1)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff_0_1(path)
    shell.assert_cd_exec(path, DIFF_0_1)
  end

  private

  SETUP = [
    'git init --quiet',
    "git config user.name 'differ'",
    "git config user.email 'differ@cyber-dojo.org'"
  ].join(' && ').freeze

  ADD_COMMIT_TAG_0 = [
    'git add .',
    "git commit --allow-empty --all --message 0 --quiet",
    "git tag 0 HEAD"
  ].join(' && ').freeze

  ADD_COMMIT_TAG_1 = [
    'git add .',
    "git commit --allow-empty --all --message 1 --quiet",
    "git tag 1 HEAD"
  ].join(' && ').freeze

  DIFF_0_1 = [
    'git diff',
    '--unified=99999999999',
    '--no-prefix',
    '--ignore-space-at-eol',
    '--find-copies-harder',
    '--indent-heuristic',
    '0',
    '1',
    '--'     # specifies to git that 0,1 are revisions and not filenames
  ].join(' ').freeze

  def shell
    @externals.shell
  end

end
