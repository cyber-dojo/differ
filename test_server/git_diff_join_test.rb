require_relative 'differ_test_base'
require_relative '../src/git_diff_join'

class GitDiffJoinTest < DifferTestBase

  def self.hex_prefix
    '74C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    old_files = { 'empty.rb' => '' }
    new_files = {}
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all

    expected_diffs =
    [
      {
        old_filename: 'empty.rb',
        new_filename: nil,
        hunks: []
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'empty.rb' => [] }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    old_files = { 'non-empty.h' => 'something' }
    new_files = {}
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    expected_diffs =
    [
      {
        old_filename: 'non-empty.h',
        new_filename: nil,
        hunks:
        [
          {
            old_start_line:1,
            deleted: [ 'something' ],
            new_start_line:0,
            added: [],
          }
        ]
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'non-empty.h' =>
      [
        {
          line: 'something',
          type: :deleted,
          number: 1
        }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    old_files = {}
    new_files = { 'empty.h' => '' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    expected_diffs =
    [
      {
        old_filename: nil,
        new_filename: 'empty.h',
        hunks: []
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'empty.h' => [] }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    old_files = {}
    new_files = { 'non-empty.c' => 'something' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    expected_diffs =
    [
      {
        old_filename: nil,
        new_filename: 'non-empty.c',
        hunks:
        [
          {
            old_start_line:0,
            deleted: [],
            new_start_line:1,
            added: [ 'something' ],
          }
        ]
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'non-empty.c' =>
      [
        { :type => :added, :line => 'something', :number => 1 }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is copied' do
    old_files = { 'plain' => '' }
    new_files = { 'copy'  => '' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    expected_diffs =
    [
      {
        old_filename: 'plain',
        new_filename: 'copy',
        hunks: []
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'copy' =>
      [
        {
          number: 1,
          type: :same,
          line: ''
        }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is copied' do
    old_files = { 'plain' => 'xxx' }
    new_files = { 'copy' => 'xxx' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    expected_diffs =
    [
      {
        old_filename: 'plain',
        new_filename: 'copy',
        hunks: []
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'copy' =>
      [
        {
          number: 1,
          type: :same,
          line: 'xxx'
        }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D0',
  'existing non-empty file is changed' do
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => 'something changed' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    actual_diffs = GitDiffParser.new(diff_lines).parse_all     
    expected_diffs =
    [
      {
        old_filename: 'non-empty.c',
        new_filename: 'non-empty.c',
        hunks:
        [
          {
            old_start_line:1,
            deleted: [ 'something' ],
            new_start_line:1,
            added: [ 'something changed' ],
          }
        ]
      }
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'non-empty.c' =>
      [
        { :type => :section, :index => 0 },
        { :type => :deleted, :line => 'something', :number => 1 },
        { :type => :added, :line => 'something changed', :number => 1 }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '35C',
  'unchanged file' do
    old_files = { 'wibble.txt' => 'content' }
    new_files = { 'wibble.txt' => 'content' }
    diff_lines = GitDiffer.new(externals).diff(old_files, new_files)
    expected =
    {
      'wibble.txt' =>
      [
        { :type => :same, :line => 'content', :number => 1}
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_join(expected, diff_lines, old_files, new_files)
    actual = git_diff_join(diff_lines, old_files, new_files)
    my_assert_equal expected, actual
  end

  include GitDiffJoin

end
