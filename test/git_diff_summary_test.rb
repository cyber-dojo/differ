require_relative 'differ_test_base'
require_app 'git_diff_parser'
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
    assert_diff_summary [ :created, nil, 'empty.h', 0,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    assert_diff_summary [ :deleted, 'empty.rb', nil, 0,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    assert_diff_summary  [ :renamed, 'plain', 'copy', 0,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    assert_diff_summary [ :renamed, 'plain', 'a/b/copy', 0,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    assert_diff_summary [ :unchanged, 'empty.py', 'empty.py', 0,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => 'something added' }
    assert_diff_summary [ :changed, 'empty.c', 'empty.c', 1,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    @was_files = {}
    @now_files = { 'non-empty.c' => "once\nupon\na\ntime" }
    assert_diff_summary [ :created, nil, 'non-empty.c', 4,0,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    @was_files = { 'non-empty.h' => "and\nthey\nall\nlived\nhappily\n" }
    @now_files = {}
    assert_diff_summary [ :deleted, 'non-empty.h', nil, 0,5,0 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    @was_files = { 'non-empty.h' => '#include<stdio.h>' }
    @now_files = { 'non-empty.h' => '#include<stdio.h>' }
    assert_diff_summary [ :unchanged, 'non-empty.h', 'non-empty.h', 0,0,1 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    @was_files = { 'plain' => "xxx\nyyy" }
    @now_files = { 'copy' => "xxx\nyyy" }
    assert_diff_summary [ :renamed, 'plain', 'copy', 0,0,2 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    @was_files = { 'a/b/plain' => "a\nb\nc" }
    @now_files = { 'copy' => "a\nb\nc" }
    assert_diff_summary [ :renamed, 'a/b/plain', 'copy', 0,0,3 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff_summary [ :renamed, 'hiker.h', 'diamond.h', 1,1,3 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    assert_diff_summary [ :renamed, '1/2/hiker.h', '3/4/diamond.h', 1,1,3 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D0',
  'non-empty file has some content added at the start' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "more\nsomething" }
    assert_diff_summary [ :changed, 'non-empty.c', 'non-empty.c', 1,0,1 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D1',
  'non-empty file has some content added at the end' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "something\nmore" }
    assert_diff_summary [ :changed, 'non-empty.c', 'non-empty.c', 1,0,1 ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D2',
  'non-empty file has some content added in the middle' do
    @was_files = { 'non-empty.c' => "a\nc"}
    @now_files = { 'non-empty.c' => "a\nB\nc" }
    assert_diff_summary [ :changed, 'non-empty.c', 'non-empty.c', 1,0,2 ]
  end

  private

  include GitDiffLib

  def assert_diff_summary(raw_expected)
    expected = raw_expected.each_slice(6).to_a.map do |diff|
      {         type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
         line_counts: { added: diff[3], deleted: diff[4], same: diff[5] }
      }
    end
    diff_lines = GitDiffer.new(externals).diff(id58, @was_files, @now_files)
    diffs = GitDiffParser.new(diff_lines, :summary).parse_all
    actual = git_diff_summary(diffs, @now_files)
    assert_equal expected, actual
  end

end
