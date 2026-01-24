# frozen_string_literal: true

require_relative 'differ_test_base'
require_relative 'spy_sheller'

class ExternalGitterTest < DifferTestBase

  def id58_setup
    externals.instance_eval { @shell = SpySheller.new }
  end

  # - - - - - - - - - - - - - - - - -

  test 'DC30B4', %w(
  | git.setup
  ) do
    expected = [
      'git init --quiet',
      "git config user.name 'differ'",
      "git config user.email 'differ@cyber-dojo.org'"
    ].join(' && ')
    git.setup(path)
    assert_shell(expected)
  end

  # - - - - - - - - - - - - - - - - -

  test 'DC38AB', %w(
  | for git.add_commit_tag_0
  ) do
    expected = [
      'git add .',
      'git commit --allow-empty --all --message 0 --quiet',
      'git tag 0 HEAD'
    ].join(' && ')
    git.add_commit_tag_0(path)
    assert_shell(expected)
  end

  test 'DC38AC', %w(
  | for git.add_commit_tag_1
  ) do
    expected = [
      'git add .',
      'git commit --allow-empty --all --message 1 --quiet',
      'git tag 1 HEAD'
    ].join(' && ')
    git.add_commit_tag_1(path)
    assert_shell(expected)
  end

  # - - - - - - - - - - - - - - - - -

  test 'DC39A2', %w(
  | git.diff_0_1
  ) do
    expected = [
      'git diff',
      '--unified=99999999999',
      '--no-prefix',
      '--ignore-space-at-eol',
      '--find-copies-harder',
      '--indent-heuristic',
      '0',
      '1',
      '--'
    ].join(' ')
    git.diff_0_1(path)
    assert_shell(expected)
  end

  private

  def assert_shell(*messages)
    assert_equal [[path] + messages], shell.spied
  end

  def path
    'a/b/c/'
  end

end
