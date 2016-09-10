#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'
require_relative './spy_sheller'

class ExternalGitterTest < LibTestBase

  def setup
    super
    ENV['DIFFER_CLASS_SHELL'] = 'SpySheller'
    @differ = Differ.new(nil, nil)
  end

  def shell; @differ.shell; end
  def git  ; @differ.git  ; end

  # - - - - - - - - - - - - - - - - -

  test 'DC30B4',
  'git.setup' do
    user_name = 'lion'
    user_email = "#{user_name}@cyber-dojo.org"
    git.setup(path, user_name, user_email)
    expect_shell(
      'git init --quiet',
      "git config user.name '#{user_name}'",
      "git config user.email '#{user_email}'"
    )
  end

  # - - - - - - - - - - - - - - - - -

  test 'F2FAD5',
  'git.add' do
    filename = 'wibble.h'
    git.add(path, filename)
    expect_shell("git add '#{filename}'")
  end

  # - - - - - - - - - - - - - - - - -

  test '7A3E16',
  'git.rm' do
    filename = 'wibble.c'
    git.rm(path, filename)
    expect_shell("git rm '#{filename}'")
  end

  # - - - - - - - - - - - - - - - - -

  test 'F728AB',
  'for git.commit' do
    tag = 6
    git.commit(path, tag)
    expect_shell(
      "git commit -a -m #{tag} --quiet",
      "git tag -m '#{tag}' #{tag} HEAD"
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '31A9A2',
  'git.diff' do
    was_tag = 2
    now_tag = 3
    options = [
      '--ignore-space-at-eol',
      '--find-copies-harder',
      '--compaction-heuristic',
      "#{was_tag}",
      "#{now_tag}"
    ].join(space)
    git.diff(path, was_tag, now_tag)
    expect_shell("git diff #{options}")
  end

  private

  def expect_shell(*messages)
    assert_equal [[path]+messages], shell.spied
  end

  def path
    'a/b/c/'
  end

  def space
   ' '
  end

end
