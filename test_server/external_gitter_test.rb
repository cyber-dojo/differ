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
    expect_shell(
      'git init --quiet',
      "git config user.name 'differ'",
      "git config user.email 'differ@cyber-dojo.org'"
    )
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
  'git.diff' do
    was_tag = 2
    now_tag = 3
    options = [
      '--unified=0',
      '--ignore-space-at-eol',
      '--find-copies-harder',
      '--indent-heuristic',
      "#{was_tag}",
      "#{now_tag}",
      '--'
    ].join(space)
    git.diff(path, was_tag, now_tag)
    expect_shell("git diff #{options}")
  end

  private

  def expect_shell(*messages)
    my_assert_equal [[path]+messages], shell.spied
  end

  def path
    'a/b/c/'
  end

  def space
   ' '
  end

end
