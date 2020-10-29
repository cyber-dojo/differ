require_relative 'differ_test_base'
require_app 'git_diff_summary'

class GitDiffSummaryTest < DifferTestBase

  def self.id58_prefix
    '74D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    @expected = []
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted is represented as []' do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    @expected = [
      {
        'old_filename' => 'empty.rb',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    @was_files = {}
    @now_files = { 'empty.h' => '' }
    @expected = [
       { 'old_filename' => nil,
         'new_filename' => 'empty.h',
         'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
       }
     ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    @expected = [
      {
        'old_filename' => 'plain',
        'new_filename' => 'copy',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    @expected = [
      {
        'old_filename' => 'plain',
        'new_filename' => 'a/b/copy',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => 'something added' }
    @expected = [
      { 'old_filename' => 'empty.c',
        'new_filename' => 'empty.c',
        'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    @was_files = {}
    @now_files = { 'non-empty.c' => 'something' }
    @expected = [
      { 'old_filename' => nil,
        'new_filename' => 'non-empty.c',
        'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    @was_files = { 'non-empty.h' => '#include<stdio.h>' }
    @now_files = { 'non-empty.h' => '#include<stdio.h>' }
    @expected = []
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    @was_files = { 'non-empty.h' => 'something' }
    @now_files = {}
    @expected = [
      { 'old_filename' => 'non-empty.h',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 1, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    @was_files = { 'plain' => 'xxx' }
    @now_files = { 'copy' => 'xxx' }
    @expected = [
      {
        'old_filename' => 'plain',
        'new_filename' => 'copy',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 1 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    @was_files = { 'a/b/plain' => 'zzz' }
    @now_files = { 'copy' => 'zzz' }
    @expected = [
      {
        'old_filename' => 'a/b/plain',
        'new_filename' => 'copy',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 1 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    @expected = [
      { 'old_filename' => 'hiker.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    @expected = [
      { 'old_filename' => '1/2/hiker.h',
        'new_filename' => '3/4/diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D0',
  'non-empty file has some content added at the start' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "more\nsomething" }
    @expected = [
      { 'old_filename' => 'non-empty.c',
        'new_filename' => 'non-empty.c',
        'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D1',
  'non-empty file has some content added at the end' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "something\nmore" }
    @expected = [
      { 'old_filename' => 'non-empty.c',
        'new_filename' => 'non-empty.c',
        'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D2',
  'non-empty file has some content added in the middle' do
    @was_files = { 'non-empty.c' => "a\nc"}
    @now_files = { 'non-empty.c' => "a\nB\nc" }
    @expected = [
      { 'old_filename' => 'non-empty.c',
        'new_filename' => 'non-empty.c',
        'line_counts' => { 'added' => 1, 'deleted' => 0, 'same' => 0 }
      }
    ]
    assert_diff_summary
  end

  private

  include GitDiffLib

  def assert_diff_summary
    git_diff = GitDiffer.new(externals).diff(id58, @was_files, @now_files)
    assert_equal @expected, git_diff_summary(git_diff, @was_files, @now_files)
  end

end
