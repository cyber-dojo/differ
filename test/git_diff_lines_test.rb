require_relative 'differ_test_base'
require_app 'git_diff_lines'

class GitDiffLinesTest < DifferTestBase

  def self.id58_prefix
    'C9s'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # empty file
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    @was_files = {}
    @now_files = { 'empty.h' => '' }

    assert_git_diff_lines [
      :created, nil, 'empty.h', 0,0,0,
      []
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A5C',
  'empty file is deleted' do
    @was_files = { 'empty.rb' => '' }
    @now_files = {}
    assert_git_diff_lines [
      :deleted, 'empty.rb', nil, 0,0,0,
      []
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ED',
  'empty file is unchanged' do
    @was_files = { 'empty.py' => '' }
    @now_files = { 'empty.py' => '' }
    assert_git_diff_lines [
        :unchanged, 'empty.py', 'empty.py', 0,0,0,
        []
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is renamed 100% identical' do
    @was_files = { 'plain' => '' }
    @now_files = { 'copy'  => '' }
    assert_git_diff_lines [
      :renamed, 'plain', 'copy', 0,0,0,
      []
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2D',
  'empty file is renamed 100% identical across dirs' do
    @was_files = { 'plain'    => '' }
    @now_files = { 'a/b/copy' => '' }
    assert_git_diff_lines [
      :renamed, 'plain', 'a/b/copy', 0,0,0,
      []
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F2E',
  'empty file has some content added' do
    @was_files = { 'empty.c' => '' }
    @now_files = { 'empty.c' => "three\nlines\nadded" }
    assert_git_diff_lines [
      :changed, 'empty.c', 'empty.c', 3,0,0,
      [
        section(0),
        added(1, 'three'),
        added(2, 'lines'),
        added(3, 'added')
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # non-empty file
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    @was_files = {}
    @now_files = { 'non-empty.c' => 'something' }
    assert_git_diff_lines [
      :created, nil, 'non-empty.c', 1,0,0,
      [
        section(0),
        added(1, 'something'),
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    @was_files = { 'non-empty.h' => "two\nlines" }
    @now_files = {}
    assert_git_diff_lines [
      :deleted, 'non-empty.h', nil, 0,2,0,
      [
        section(0),
        deleted(1, 'two'),
        deleted(2, 'lines')
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '21D',
  'non-empty file is unchanged' do
    @was_files = { 'non-empty.h' => '#include<stdio.h>' }
    @now_files = { 'non-empty.h' => '#include<stdio.h>' }
    assert_git_diff_lines [
      :unchanged, 'non-empty.h', 'non-empty.h', 0,0,1,
      [
        same(1, '#include<stdio.h>'),
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is renamed 100% identical' do
    @was_files = { 'plain' => 'xxx' }
    @now_files = { 'copy' => 'xxx' }
    assert_git_diff_lines [
      :renamed, 'plain', 'copy', 0,0,1,
      [
        same(1, 'xxx'),
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BA7',
  'non-empty file is renamed 100% identical across dirs' do
    @was_files = { 'a/b/plain' => "a\nb\nc\nd" }
    @now_files = { 'copy' => "a\nb\nc\nd" }
    assert_git_diff_lines [
      :renamed, 'a/b/plain', 'copy', 0,0,4,
      [
        same(1, 'a'),
        same(2, 'b'),
        same(3, 'c'),
        same(4, 'd')
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA8',
  'non-empty file is renamed <100% identical' do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_git_diff_lines [
      :renamed, 'hiker.h', 'diamond.h', 1,1,3,
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA9',
  'non-empty file is renamed <100% identical across dirs' do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { '3/4/diamond.h' => "a\nb\nX\nd" }
    assert_git_diff_lines [
      :renamed, '1/2/hiker.h', '3/4/diamond.h', 1,1,3,
      [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D0',
  'non-empty file has some content added at the start' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "more\nsomething" }
    assert_git_diff_lines [
      :changed, 'non-empty.c', 'non-empty.c', 1,0,1,
      [
        section(0),
        added(1, 'more'),
        same(2, 'something'),
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D1',
  'non-empty file has some content added at the end' do
    @was_files = { 'non-empty.c' => 'something' }
    @now_files = { 'non-empty.c' => "something\nmore" }
    assert_git_diff_lines [
      :changed, 'non-empty.c', 'non-empty.c', 1,0,1,
      [
        same(1, 'something'),
        section(0),
        added(2, 'more'),
      ]
    ]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D2',
  'non-empty file has some content added in the middle' do
    @was_files = { 'non-empty.c' => "a\nc"}
    @now_files = { 'non-empty.c' => "a\nB\nc" }
    assert_git_diff_lines [
      :changed, 'non-empty.c', 'non-empty.c', 1,0,2,
      [
        same(1, 'a'),
        section(0),
        added(2, 'B'),
        same(3, 'c')
      ]
    ]
  end

  private

  def assert_git_diff_lines(raw_expected)

    exercise_name = 'Fizz Buzz'
    language_name = 'C (gcc), assert'
    manifest = creator.build_manifest(exercise_name, language_name)
    id = model.kata_create(manifest)['kata_create']

    model.kata_ran_tests(
      id,
      was_index=1,
      plain(@was_files),
      stdout={
        'content' => 'this is stdout',
        'truncated' => false
      },
      stderr={
        'content' => 'this is stderr',
        'truncated' => false
      },
      status='0',
      summary = {
        'duration' => 0.45634,
        'colour' => 'red',
        'predicted' => 'none'
      }
    )

    model.kata_ran_tests(
      id,
      now_index=2,
      plain(@now_files),
      stdout={
        'content' => 'this is stdout',
        'truncated' => false
      },
      stderr={
        'content' => 'this is stderr',
        'truncated' => false
      },
      status='0',
      summary = {
        'duration' => 0.457764,
        'colour' => 'green',
        'predicted' => 'none'
      }
    )

    diff = differ.diff_lines(id:id, was_index:was_index, now_index:now_index)

    expected = expected_diff(raw_expected)

    diagnostic = [
      "expected=#{JSON.pretty_generate(expected)}",
      "diff=#{JSON.pretty_generate(diff)}"
    ].join("\n")

    assert diff.include?(expected[0]), diagnostic
  end

  # - - - - - - - - - - - - -

  def plain(files)
    files.map{|filename,content|
      [filename,{
        'content' => content,
        'truncated' => false
      }]
    }.to_h
  end

  # - - - - - - - - - - - - -

  def expected_diff(raw_expected)
    raw_expected.each_slice(7).to_a.map do |diff|
      {         type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
               lines: diff[6],
         line_counts: {
             added:diff[3],
           deleted:diff[4],
              same:diff[5]
         },
      }
    end
  end

  def section(index)
    { :type => :section, index:index }
  end

  def same(number, line)
    one_line(:same, number, line)
  end

  def deleted(number, line)
    one_line(:deleted, number, line)
  end

  def added(number, line)
    one_line(:added, number, line)
  end

  def one_line(type, number, line)
    { type:type, number:number, line:line }
  end

end
