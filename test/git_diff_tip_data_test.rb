require_relative 'differ_test_base'
require_app 'git_diff_lib'

class GitDiffTipDataTest < DifferTestBase

  def self.id58_prefix
    '74D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    old_files = { 'empty.py' => '' }
    new_files = { 'empty.py' => '' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted is represented as {}' do
    old_files = { 'empty.rb' => '' }
    new_files = {}
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    old_files = {}
    new_files = { 'empty.h' => '' }
    expected = { 'empty.h' => { 'added' => 1,'deleted' => 0 } }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    old_files = { 'plain' => '' }
    new_files = { 'copy'  => '' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    old_files = { 'plain'    => '' }
    new_files = { 'a/b/copy' => '' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    old_files = { 'empty.c' => '' }
    new_files = { 'empty.c' => 'something added' }
    expected = { 'empty.c' => { 'added' => 1, 'deleted' => 0 } }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    old_files = { 'non-empty.h' => '#include<stdio.h>' }
    new_files = { 'non-empty.h' => '#include<stdio.h>' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    old_files = { 'non-empty.h' => 'something' }
    new_files = {}
    expected = { 'non-empty.h' => { 'added' => 0, 'deleted' => 1 } }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    old_files = {}
    new_files = { 'non-empty.c' => 'something' }
    expected = { 'non-empty.c' => { 'added' => 1, 'deleted' => 0 } }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    old_files = { 'plain' => 'xxx' }
    new_files = { 'copy' => 'xxx' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    old_files = { 'a/b/plain' => 'zzz' }
    new_files = { 'copy' => 'zzz' }
    expected = {}
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    new_files = { 'diamond.h' => "a\nb\nX\nd" }
    expected =
    {
      'diamond.h' => { 'added' => 1, 'deleted' => 1 }
    }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    old_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    new_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    expected =
    {
      '3/4/diamond.h' => { 'added' => 1, 'deleted' => 1 }
    }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D0',
  'non-empty file has some content added at the start' do
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => "more\nsomething" }
    expected =
    {
      'non-empty.c' => { 'added' => 1, 'deleted' => 0 }
    }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D1',
  'non-empty file has some content added at the end' do
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => "something\nmore" }
    expected =
    {
      'non-empty.c' => { 'added' => 1, 'deleted' => 0 }
    }
    assert_tip_data(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D2',
  'non-empty file has some content added in the middle' do
    old_files = { 'non-empty.c' => "a\nc"}
    new_files = { 'non-empty.c' => "a\nB\nc" }
    expected =
    {
      'non-empty.c' => { 'added' => 1, 'deleted' => 0 }
    }
    assert_tip_data(expected, old_files, new_files)
  end

  private

  include GitDiffLib

  def assert_tip_data(expected, old_files, new_files)
    diff_lines = GitDiffer.new(externals).diff(id58, old_files, new_files)
    actual = git_diff_tip_data(diff_lines, old_files, new_files)
    assert_equal expected, actual
  end

end
