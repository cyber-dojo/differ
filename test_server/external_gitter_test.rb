require_relative 'differ_test_base'
require_relative 'spy_sheller'

class ExternalGitterTest < DifferTestBase

  def self.hex_prefix
    'DC3'
  end

  def hex_setup
    externals.shell = SpySheller.new
  end

  # - - - - - - - - - - - - - - - - -

  test '0B4',
  'git.setup' do
    git.setup(path)
    expect_shell([
      'git init --quiet',
      "git config user.name 'differ'",
      "git config user.email 'differ@cyber-dojo.org'"
    ].join(' && '))
  end

  # - - - - - - - - - - - - - - - - -

  test '8AB',
  'for git.add_commit_tag' do
    tag = 6
    git.add_commit_tag(path, tag)
    expect_shell(
      'git add .',
      "git commit --allow-empty --all --message #{tag} --quiet",
      "git tag #{tag} HEAD"
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '9A2',
  'git.diff_0_1' do
    expected = [
      'git diff',
      '--unified=0',
      '--no-prefix',
      '--ignore-space-at-eol',
      '--find-copies-harder',
      '--indent-heuristic',
      '0',
      '1',
      '--'
    ].join(' ')
    git.diff_0_1(path)
    expect_shell(expected)
  end

  private

  def expect_shell(*messages)
    assert_equal [[path]+messages], shell.spied
  end

  def path
    'a/b/c/'
  end

end
