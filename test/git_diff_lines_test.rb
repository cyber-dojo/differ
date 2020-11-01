require_relative 'differ_test_base'
require_app 'git_diff_lines'

class GitDiffLinesTest < DifferTestBase

  def self.id58_prefix
    'C9s'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    assert_git_diff_lines [
      :deleted, 'empty.rb', nil, [ deleted(1,'') ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    @was_files = {}
    @now_files = { 'empty.h' => '' }
    assert_git_diff_lines [
      :created, nil, 'empty.h', [ added(1,'') ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    assert_git_diff_lines [
        :unchanged, 'empty.py', 'empty.py', [ same(1,'') ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    assert_git_diff_lines [
      :renamed, 'plain', 'copy', [ same(1,'') ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    assert_git_diff_lines [
      :renamed, 'plain', 'a/b/copy', [ same(1,'') ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => 'something added' }
    assert_git_diff_lines [
      :changed, 'empty.c', 'empty.c',
      [
        section(0),
        added(1, 'something added')
      ]
    ]
  end

=begin

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

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    old_files = { 'a/b/plain' => 'zzz' }
    new_files = { 'copy' => 'zzz' }
    expected =
    {
      'copy' =>
      [
        same(1, 'zzz'),
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    new_files = { 'diamond.h' => "a\nb\nX\nd" }
    expected =
    {
      'diamond.h' =>
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    }
    assert_join(expected, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    old_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    new_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    expected =
    {
      '3/4/diamond.h' =>
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
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

  private
=end

  include GitDiffLib


  def assert_git_diff_lines(raw_expected)
    expected = raw_expected.each_slice(4).to_a.map do |diff|
      {         type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
               lines: diff[3]
      }
    end
    diff_lines = GitDiffer.new(externals).diff(id58, @was_files, @now_files)
    diffs = GitDiffParser.new(diff_lines, :lines).parse_all
    actual = git_diff_lines(diffs, @now_files)
    assert_equal expected, actual
  end

  def XXX_assert_join(expected, old_files, new_files)
    diff_lines = GitDiffer.new(externals).diff(id58, old_files, new_files)
    actual = git_diff_join(diff_lines, old_files, new_files)
    assert_equal expected, actual
  end

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
