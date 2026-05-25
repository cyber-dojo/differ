require_relative 'client_test_base'

class DiffTest < ClientTestBase

  # - - - - - - - - - - - - - - - - - - - -
  # delete file
  # - - - - - - - - - - - - - - - - - - - -

  test '2q0313', %w(
  | deleted empty file
  ) do
    @old_files = { 'hiker.h' => '' }
    @new_files = {}
    assert_diff(
      {
        'type' => 'deleted',
        'old_filename' => 'hiker.h',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0314', %w(
  | deleted empty file in nested sub-dir
  ) do
    @old_files = { '6/7/8/hiker.h' => '' }
    @new_files = {}
    assert_diff(
      {
        'type' => 'deleted',
        'old_filename' => '6/7/8/hiker.h',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0FE9', %w(
  | deleted non-empty file shows as all lines deleted
  ) do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = {}
    assert_diff(
      {
        'type' => 'deleted',
        'old_filename' => 'hiker.h',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 4, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0FEA', %w(
  | deleted non-empty file in nested sub-dir shows as all lines deleted
  ) do
    @old_files = { '4/5/6/7/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = {}
    assert_diff(
      {
        'type' => 'deleted',
        'old_filename' => '4/5/6/7/hiker.h',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 4, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete content
  # - - - - - - - - - - - - - - - - - - - -

  test '2q0B67', %w(
  | all lines deleted but file not deleted
  | shows as all lines deleted
  ) do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'hiker.h' => '' }
    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 'hiker.h',
        'new_filename' => 'hiker.h',
        'line_counts' => { 'added' => 0, 'deleted' => 4, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0B68', %w(
  | all lines deleted but nested sub-dir file not deleted
  | shows as all lines deleted
  ) do
    @old_files = { 'r/t/y/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'r/t/y/hiker.h' => '' }
    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 'r/t/y/hiker.h',
        'new_filename' => 'r/t/y/hiker.h',
        'line_counts' => { 'added' => 0, 'deleted' => 4, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # new file
  # - - - - - - - - - - - - - - - - - - - -

  test '2q095F', %w(
  | created new empty file
  ) do
    @old_files = {}
    @new_files = { 'diamond.h' => '' }
    assert_diff(
      {
        'type' => 'created',
        'old_filename' => nil,
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0960', %w(
  | created empty file in nested sub-dir
  ) do
    @old_files = {}
    @new_files = { 'a/b/c/diamond.h' => '' }
    assert_diff(
      {
        'type' => 'created',
        'old_filename' => nil,
        'new_filename' => 'a/b/c/diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q02C3', %w(
  | created non-empty file
  ) do
    @old_files = {}
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        'type' => 'created',
        'old_filename' => nil,
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 4, 'deleted' => 0, 'same' => 0 },
        'lines' => [
          section(0),
          added(1, 'a'),
          added(2, 'b'),
          added(3, 'c'),
          added(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q02C4', %w(
  | created non-empty file in nested sub-dir
  ) do
    @old_files = {}
    @new_files = { 'q/w/e/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        'type' => 'created',
        'old_filename' => nil,
        'new_filename' => 'q/w/e/diamond.h',
        'line_counts' => { 'added' => 4, 'deleted' => 0, 'same' => 0 },
        'lines' => [
          section(0),
          added(1, 'a'),
          added(2, 'b'),
          added(3, 'c'),
          added(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test '2q0E3E', %w(
  | changed non-empty file
  ) do
    @old_files = { 'diamond.h' => 'a' }
    @new_files = { 'diamond.h' => 'b' }
    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 'diamond.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a'),
          added(1, 'b')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0E3F', %w(
  | changed non-empty file in nested sub-dir
  ) do
    @old_files = { 't/y/u/diamond.h' => 'a1' }
    @new_files = { 't/y/u/diamond.h' => 'b2' }
    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 't/y/u/diamond.h',
        'new_filename' => 't/y/u/diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 0 },
        'lines' => [
          section(0),
          deleted(1, 'a1'),
          added(1, 'b2')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0B9E', %w(
  | changed non-empty file shows as deleted and added lines
  | with each hunk in its own indexed section
  ) do
    @old_files = {
      'diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>', # no g
          '',
          'void diamond(char)', # no ;
          '',
          '#endif'
        ].join("\n")
    }
    @new_files = {
      'diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <string>',
          '',
          'void diamond(char);',
          '',
          '#endif'
        ].join("\n")
    }

    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 'diamond.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 2, 'deleted' => 2, 'same' => 6 },
        'lines' => [
          same(1, '#ifndef DIAMOND'),
          same(2, '#define DIAMOND'),
          same(3, ''),

          section(0),
          deleted(4, '#include <strin>'),
          added(4, '#include <string>'),
          same(5, ''),

          section(1),
          deleted(6, 'void diamond(char)'),
          added(6, 'void diamond(char);'),
          same(7, ''),
          same(8, '#endif')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0B9F', %w(
  | changed non-empty file in nested sub-dir shows as deleted and added lines
  | with each hunk in its own indexed section
  ) do
    @old_files = {
      'a/b/c/diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>', # no g
          '',
          'void diamond(char)', # no ;
          '',
          '#endif'
        ].join("\n")
    }
    @new_files = {
      'a/b/c/diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <string>',
          '',
          'void diamond(char);',
          '',
          '#endif'
        ].join("\n")
    }

    assert_diff(
      {
        'type' => 'changed',
        'old_filename' => 'a/b/c/diamond.h',
        'new_filename' => 'a/b/c/diamond.h',
        'line_counts' => { 'added' => 2, 'deleted' => 2, 'same' => 6 },
        'lines' => [
          same(1, '#ifndef DIAMOND'),
          same(2, '#define DIAMOND'),
          same(3, ''),

          section(0),
          deleted(4, '#include <strin>'),
          added(4, '#include <string>'),
          same(5, ''),

          section(1),
          deleted(6, 'void diamond(char)'),
          added(6, 'void diamond(char);'),
          same(7, ''),
          same(8, '#endif')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # renamed file
  # - - - - - - - - - - - - - - - - - - - -

  test '2q0E50', %w(
  | 100% identical renamed file
  ) do
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        'type' => 'renamed',
        'old_filename' => 'hiker.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 4 },
        'lines' => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0E51', %w(
  | 100% identical renamed file in nested sub-dir
  ) do
    @old_files = { 'a/f/d/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/f/d/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        'type' => 'renamed',
        'old_filename' => 'a/f/d/hiker.h',
        'new_filename' => 'a/f/d/diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 4 },
        'lines' => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0FDB', %w(
  | <100% identical rename
  ) do
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      {
        'type' => 'renamed',
        'old_filename' => 'hiker.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 3 },
        'lines' => [
          same(1, 'a'),
          same(2, 'b'),
          section(0),
          deleted(3, 'c'),
          added(3, 'X'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0FDC', %w(
  | <100% identical renamed in nested sub-dir
  ) do
    @old_files = { 'a/b/c/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/b/c/diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      {
        'type' => 'renamed',
        'old_filename' => 'a/b/c/hiker.h',
        'new_filename' => 'a/b/c/diamond.h',
        'line_counts' => { 'added' => 1, 'deleted' => 1, 'same' => 3 },
        'lines' => [
          same(1, 'a'),
          same(2, 'b'),
          section(0),
          deleted(3, 'c'),
          added(3, 'X'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # unchanged files
  # - - - - - - - - - - - - - - - - - - - -

  test '2q0AEC', %w(
  | unchanged empty files
  ) do
    @old_files = { 'diamond.h' => '' }
    @new_files = { 'diamond.h' => '' }
    assert_diff(
      {
        'type' => 'unchanged',
        'old_filename' => 'diamond.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q07FF', %w(
  | unchanged empty-file in nested sub-dir
  ) do
    @old_files = { 'w/e/r/diamond.h' => '' }
    @new_files = { 'w/e/r/diamond.h' => '' }
    assert_diff(
      {
        'type' => 'unchanged',
        'old_filename' => 'w/e/r/diamond.h',
        'new_filename' => 'w/e/r/diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 },
        'lines' => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0365', %w(
  | unchanged non-empty file
  ) do
    @old_files = { 'diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        'type' => 'unchanged',
        'old_filename' => 'diamond.h',
        'new_filename' => 'diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 4 },
        'lines' => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2q0366', %w(
  | unchanged non-empty file in nested sub-dir shows as all lines same
  ) do
    @old_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    @new_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    assert_diff(
      {
        'type' => 'unchanged',
        'old_filename' => 'r/t/y/diamond.h',
        'new_filename' => 'r/t/y/diamond.h',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 4 },
        'lines' => [
          same(1, 'a'),
          same(2, 'bb'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  private

  def assert_diff(expected)
    assert_diff_lines(expected)
    expected.delete('lines')
    assert_diff_summary(expected)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff_lines(expected)
    diff = differ.diff_lines(was_files: @old_files, now_files: @new_files)
    assert diff.include?(expected), diff
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff_summary(expected)
    diff = differ.diff_summary(was_files: @old_files, now_files: @new_files)
    assert diff.include?(expected), diff
  end

  # - - - - - - - - - - - - - - - - - - - -

  def deleted(number, text)
    line(text, 'deleted', number)
  end

  def same(number, text)
    line(text, 'same', number)
  end

  def added(number, text)
    line(text, 'added', number)
  end

  def line(text, type, number)
    { 'line' => text, 'type' => type, 'number' => number }
  end

  def section(index)
    { 'type' => 'section', 'index' => index }
  end

end
