require_relative 'differ_test_base'
require_app 'git_diff_summary'

class GitDiffSummaryTest < DifferTestBase

  def self.id58_prefix
    '74D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    @was_files = {}
    @now_files = { 'empty.h' => '' }
    @expected = [ :created, nil, 'empty.h', 0,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    @expected = [ :deleted, 'empty.rb', nil, 0,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    @expected = [ :renamed, 'plain', 'copy', 0,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    @expected = [ :renamed, 'plain', 'a/b/copy', 0,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    @expected = [ :unchanged, 'empty.py', 'empty.py', 0,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => 'something added' }
    @expected = [ :changed, 'empty.c', 'empty.c', 1,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    @was_files = {}
    @now_files = { 'non-empty.c' => "once\nupon\na\ntime" }
    @expected = [ :created, nil, 'non-empty.c', 4,0,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    @was_files = { 'non-empty.h' => "and\nthey\nall\nlived\nhappily\n" }
    @now_files = {}
    @expected = [ :deleted, 'non-empty.h', nil, 0,5,0 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    @was_files = { 'non-empty.h' => '#include<stdio.h>' }
    @now_files = { 'non-empty.h' => '#include<stdio.h>' }
    @expected = [ :unchanged, 'non-empty.h', 'non-empty.h', 0,0,1 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    @was_files = { 'plain' => "xxx\nyyy" }
    @now_files = { 'copy' => "xxx\nyyy" }
    @expected = [ :renamed, 'plain', 'copy', 0,0,2 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    @was_files = { 'a/b/plain' => "a\nb\nc" }
    @now_files = { 'copy' => "a\nb\nc" }
    @expected = [ :renamed, 'a/b/plain', 'copy', 0,0,3 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    @expected = [ :renamed, 'hiker.h', 'diamond.h', 1,1,3 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    @expected = [ :renamed, '1/2/hiker.h', '3/4/diamond.h', 1,1,3 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D0',
  'non-empty file has some content added at the start' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "more\nsomething" }
    @expected = [ :changed, 'non-empty.c', 'non-empty.c', 1,0,1 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D1',
  'non-empty file has some content added at the end' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "something\nmore" }
    @expected = [ :changed, 'non-empty.c', 'non-empty.c', 1,0,1 ]
    assert_diff_summary
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D2',
  'non-empty file has some content added in the middle' do
    @was_files = { 'non-empty.c' => "a\nc"}
    @now_files = { 'non-empty.c' => "a\nB\nc" }
    @expected = [ :changed, 'non-empty.c', 'non-empty.c', 1,0,2 ]
    assert_diff_summary
  end

  private

  include GitDiffLib

  def assert_diff_summary
    expected = @expected.each_slice(6).to_a.map do |diff|
      { type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
        line_counts: { added: diff[3], deleted: diff[4], same: diff[5] }
      }
    end
    git_diff = GitDiffer.new(externals).diff(id58, @was_files, @now_files)
    actual = git_diff_summary(git_diff, @now_files)
    assert_equal expected, actual
  end

end
