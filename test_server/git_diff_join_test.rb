require_relative 'differ_test_base'
require_relative '../src/git_diff_join'

class GitDiffJoinTest < DifferTestBase

  def self.hex_prefix
    '74C'
  end

  test 'A5C',
  'empty file is deleted' do
    # $ git init
    # $ touch empty.rb
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ rm empty.rb
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/empty.rb b/empty.rb',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ].join("\n")

    expected_diffs =
    {
      'empty.rb' =>
      {
        was_filename: 'empty.rb',
        now_filename: nil,
        chunks: []
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'empty.rb' => [] }
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0C6',
  'non-empty file is deleted' do
    # $ git init
    # $ echo -n something > non-empty.h
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ rm non-empty.h
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/non-empty.h b/non-empty.h',
      'deleted file mode 100644',
      'index a459bc2..0000000',
      '--- a/non-empty.h',
      '+++ /dev/null',
      '@@ -1 +0,0 @@',
      '-something',
      '\\ No newline at end of file'
    ].join("\n")

    expected_diffs =
    {
      "non-empty.h"=>
      {
        was_filename: "non-empty.h",
        now_filename: nil,
        chunks:
        [
          {
            was: { start_line:1, size:1 },
            now: { start_line:0, size:0 },
            deleted_lines: [ "something" ],
            added_lines: [],
          }
        ]
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
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
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A2C',
  'empty file is created' do
    # $ git init
    # $ echo x > dummy
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ touch empty.h
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/empty.h b/empty.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    ].join("\n")

    expected_diffs =
    {
      'empty.h' =>
      {
        was_filename: nil,
        now_filename: 'empty.h',
        chunks: []
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'empty.h' => [] }
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'non-empty file is created' do
    # $ git init
    # $ echo x > dummy
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ echo -n 'something' > non-empty.c
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/non-empty.c b/non-empty.c',
      'new file mode 100644',
      'index 0000000..a459bc2',
      '--- /dev/null',
      '+++ b/non-empty.c',
      '@@ -0,0 +1 @@',
      '+something',
      '\\ No newline at end of file'
    ].join("\n")

    expected_diffs =
    {
      'non-empty.c' =>
      {
        was_filename: nil,
        now_filename: 'non-empty.c',
        chunks:
        [
          {
            was: { start_line:0, size:0 },
            now: { start_line:1, size:1 },
            deleted_lines: [],
            added_lines: [ 'something' ],
          }
        ]
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'non-empty.c' =>
      [
        { :type => :added, :line => 'something', :number => 1 }
      ]
    }
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA7',
  'non-empty file is copied' do
    # $ echo xxx > plain
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ mv plain copy
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/plain b/copy',
      'similarity index 100%',
      'copy from plain',
      'copy to copy'
    ].join("\n")

    expected_diffs =
    {
      'copy' =>
      {
        was_filename: 'plain',
        now_filename: 'copy',
        chunks: []
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'copy' => [] }
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D0',
  'existing file is changed' do
    # Note use of -n in the echoes. This is to get the \\No newline at end of file
    # $ git init
    # $ echo -n 'something' > non-empty.c
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ echo -n 'something changed' > non-empty.c
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    diff_lines =
    [
      'diff --git a/non-empty.c b/non-empty.c',
      'index a459bc2..605f7ff 100644',
      '--- a/non-empty.c',
      '+++ b/non-empty.c',
      '@@ -1 +1 @@',
      '-something',
      '\\ No newline at end of file',
      '+something changed',
      '\\ No newline at end of file',
    ].join("\n")

    expected_diffs =
    {
      'non-empty.c' =>
      {
        was_filename: 'non-empty.c',
        now_filename: 'non-empty.c',
        chunks:
        [
          {
            was: { start_line:1, size:1 },
            now: { start_line:1, size:1 },
            deleted_lines: [ 'something' ],
            added_lines: [ 'something changed' ],
          }
        ]
      }
    }
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
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
    assert_join(expected, diff_lines, visible_files = {})
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '35C',
  'unchanged file' do
    diff_lines = [].join("\n")
    expected_diffs = {}
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    assert_equal expected_diffs, actual_diffs

    visible_files = { 'wibble.txt' => 'content' }
    expected =
    {
      'wibble.txt' =>
      [
        { :type => :same, :line => 'content', :number => 1}
      ]
    }
    assert_join(expected, diff_lines, visible_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_join(expected, diff_lines, visible_files)
    actual = git_diff_join(diff_lines, visible_files)
    my_assert_equal expected, actual
  end

  include GitDiffJoin

end
