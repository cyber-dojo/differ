require_relative 'differ_test_base'
require_relative '../src/git_diff_join'

class GitDiffJoinTest < DifferTestBase

  def self.hex_prefix
    '74C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    old_files = { 'empty.py' => '' }
    new_files = { 'empty.py' => '' }
    expected = { 'empty.py' => [] }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    old_files = { 'empty.rb' => '' }
    new_files = {}
    expected = { 'empty.rb' => [] }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    old_files = {}
    new_files = { 'empty.h' => '' }
    expected = { 'empty.h' => [] }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    old_files = { 'plain' => '' }
    new_files = { 'copy'  => '' }
    expected = { 'copy' => [] }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    old_files = { 'empty.c' => '' }
    new_files = { 'empty.c' => 'something added' }
    expected = {
      'empty.c' =>
      [
        section(0),
        added(1, 'something added')
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    old_files = { 'non-empty.h' => '#include<stdio.h>' }
    new_files = { 'non-empty.h' => '#include<stdio.h>' }
    expected =
    {
      'non-empty.h' =>
      [
        same(1, '#include<stdio.h>'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    old_files = { 'non-empty.h' => 'something' }
    new_files = {}
    expected =
    {
      'non-empty.h' =>
      [
        section(0),
        deleted(1, 'something'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    old_files = {}
    new_files = { 'non-empty.c' => 'something' }
    expected =
    {
      'non-empty.c' =>
      [
        section(0),
        added(1, 'something'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    old_files = { 'plain' => 'xxx' }
    new_files = { 'copy' => 'xxx' }
    expected =
    {
      'copy' =>
      [
        same(1, 'xxx'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D0',
  'non-empty file has some content added at the start' do
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => "more\nsomething" }
    expected =
    {
      'non-empty.c' =>
      [
        section(0),
        added(1, 'more'),
        same(2, 'something'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D1',
  'non-empty file has some content added at the end' do
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => "something\nmore" }
    expected =
    {
      'non-empty.c' =>
      [
        same(1, 'something'),
        section(0),
        added(2, 'more'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D2',
  'non-empty file has some content added in the middle' do
    old_files = { 'non-empty.c' => "a\nc"}
    new_files = { 'non-empty.c' => "a\nB\nc" }
    expected =
    {
      'non-empty.c' =>
      [
        same(1, 'a'),
        section(0),
        added(2, 'B'),
        same(3, 'c')
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_join(expected, old_files, new_files)
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual = git_diff_join(diff_lines, old_files, new_files)
    assert_equal expected, actual
  end

  include GitDiffJoin

  def section(index)
    { :type => :section, index:index }
  end

  def same(number, line)
    src(:same, number, line)
  end

  def deleted(number, line)
    src(:deleted, number, line)
  end

  def added(number, line)
    src(:added, number, line)
  end

  def src(type, number, line)
    { type:type, number:number, line:line }
  end

end
