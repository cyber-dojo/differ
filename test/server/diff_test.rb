require_relative 'differ_test_base'

class DiffTest < DifferTestBase

  # - - - - - - - - - - - - - - - - - - - -
  # delete file
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A1B', %w(
  | deleted empty file
  ) do
    @was_files = { 'hiker.h' => '' }
    @now_files = {}
    assert_diff(
      type: :deleted,
      old_filename: 'hiker.h',
      new_filename: nil,
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A1C', %w(
  | deleted empty file in nested sub-dir
  ) do
    @was_files = { '6/7/8/hiker.h' => '' }
    @now_files = {}
    assert_diff(
      type: :deleted,
      old_filename: '6/7/8/hiker.h',
      new_filename: nil,
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A1D', %w(
  | deleted non-empty file shows as all lines deleted
  ) do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = {}
    assert_diff(
      type: :deleted,
      old_filename: 'hiker.h',
      new_filename: nil,
      line_counts: { added: 0, deleted: 4, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a'),
        deleted(2, 'b'),
        deleted(3, 'c'),
        deleted(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A1E', %w(
  | deleted non-empty file in nested sub-dir shows as all lines deleted
  ) do
    @was_files = { '4/5/6/7/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = {}
    assert_diff(
      type: :deleted,
      old_filename: '4/5/6/7/hiker.h',
      new_filename: nil,
      line_counts: { added: 0, deleted: 4, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a'),
        deleted(2, 'b'),
        deleted(3, 'c'),
        deleted(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete content
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A2B', %w(
  | all lines deleted but file not deleted
  | shows as all lines deleted
  ) do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { 'hiker.h' => '' }
    assert_diff(
      type: :changed,
      old_filename: 'hiker.h',
      new_filename: 'hiker.h',
      line_counts: { added: 0, deleted: 4, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a'),
        deleted(2, 'b'),
        deleted(3, 'c'),
        deleted(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3A2C', %w(
  | all lines deleted but nested sub-dir file not deleted
  | shows as all lines deleted
  ) do
    @was_files = { 'r/t/y/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { 'r/t/y/hiker.h' => '' }
    assert_diff(
      type: :changed,
      old_filename: 'r/t/y/hiker.h',
      new_filename: 'r/t/y/hiker.h',
      line_counts: { added: 0, deleted: 4, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a'),
        deleted(2, 'b'),
        deleted(3, 'c'),
        deleted(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # new file
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3B1B', %w(
  | created new empty file
  ) do
    @was_files = {}
    @now_files = { 'diamond.h' => '' }
    assert_diff(
      type: :created,
      old_filename: nil,
      new_filename: 'diamond.h',
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3B1C', %w(
  | created empty file in nested sub-dir
  ) do
    @was_files = {}
    @now_files = { 'a/b/c/diamond.h' => '' }
    assert_diff(
      type: :created,
      old_filename: nil,
      new_filename: 'a/b/c/diamond.h',
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3B1D', %w(
  | created non-empty file
  ) do
    @was_files = {}
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      type: :created,
      old_filename: nil,
      new_filename: 'diamond.h',
      line_counts: { added: 4, deleted: 0, same: 0 },
      lines: [
        section(0),
        added(1, 'a'),
        added(2, 'b'),
        added(3, 'c'),
        added(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3B1E', %w(
  | created non-empty file in nested sub-dir
  ) do
    @was_files = {}
    @now_files = { 'q/w/e/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      type: :created,
      old_filename: nil,
      new_filename: 'q/w/e/diamond.h',
      line_counts: { added: 4, deleted: 0, same: 0 },
      lines: [
        section(0),
        added(1, 'a'),
        added(2, 'b'),
        added(3, 'c'),
        added(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3C1B', %w(
  | changed non-empty file
  ) do
    @was_files = { 'diamond.h' => 'a' }
    @now_files = { 'diamond.h' => 'b' }
    assert_diff(
      type: :changed,
      old_filename: 'diamond.h',
      new_filename: 'diamond.h',
      line_counts: { added: 1, deleted: 1, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a'),
        added(1, 'b')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3C1C', %w(
  | changed non-empty file in nested sub-dir
  ) do
    @was_files = { 't/y/u/diamond.h' => 'a1' }
    @now_files = { 't/y/u/diamond.h' => 'b2' }
    assert_diff(
      type: :changed,
      old_filename: 't/y/u/diamond.h',
      new_filename: 't/y/u/diamond.h',
      line_counts: { added: 1, deleted: 1, same: 0 },
      lines: [
        section(0),
        deleted(1, 'a1'),
        added(1, 'b2')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3C1D', %w(
  | changed non-empty file shows as deleted and added lines
  | with each hunk in its own indexed section
  ) do
    @was_files = {
      'diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>',
          '',
          'void diamond(char)',
          '',
          '#endif'
        ].join("\n")
    }
    @now_files = {
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
      type: :changed,
      old_filename: 'diamond.h',
      new_filename: 'diamond.h',
      line_counts: { added: 2, deleted: 2, same: 6 },
      lines: [
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
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3C1E', %w(
  | changed non-empty file in nested sub-dir shows as deleted and added lines
  | with each hunk in its own indexed section
  ) do
    @was_files = {
      'a/b/c/diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>',
          '',
          'void diamond(char)',
          '',
          '#endif'
        ].join("\n")
    }
    @now_files = {
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
      type: :changed,
      old_filename: 'a/b/c/diamond.h',
      new_filename: 'a/b/c/diamond.h',
      line_counts: { added: 2, deleted: 2, same: 6 },
      lines: [
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
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # renamed file
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3D1B', %w(
  | 100% identical renamed file
  ) do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      type: :renamed,
      old_filename: 'hiker.h',
      new_filename: 'diamond.h',
      line_counts: { added: 0, deleted: 0, same: 4 },
      lines: [
        same(1, 'a'),
        same(2, 'b'),
        same(3, 'c'),
        same(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3D1C', %w(
  | 100% identical renamed file in nested sub-dir
  ) do
    @was_files = { 'a/f/d/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'a/f/d/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      type: :renamed,
      old_filename: 'a/f/d/hiker.h',
      new_filename: 'a/f/d/diamond.h',
      line_counts: { added: 0, deleted: 0, same: 4 },
      lines: [
        same(1, 'a'),
        same(2, 'b'),
        same(3, 'c'),
        same(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3D1D', %w(
  | <100% identical rename
  ) do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      type: :renamed,
      old_filename: 'hiker.h',
      new_filename: 'diamond.h',
      line_counts: { added: 1, deleted: 1, same: 3 },
      lines: [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3D1E', %w(
  | <100% identical renamed in nested sub-dir
  ) do
    @was_files = { 'a/b/c/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'a/b/c/diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      type: :renamed,
      old_filename: 'a/b/c/hiker.h',
      new_filename: 'a/b/c/diamond.h',
      line_counts: { added: 1, deleted: 1, same: 3 },
      lines: [
        same(1, 'a'),
        same(2, 'b'),
        section(0),
        deleted(3, 'c'),
        added(3, 'X'),
        same(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # unchanged files
  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3E1B', %w(
  | unchanged empty files
  ) do
    @was_files = { 'diamond.h' => '' }
    @now_files = { 'diamond.h' => '' }
    assert_diff(
      type: :unchanged,
      old_filename: 'diamond.h',
      new_filename: 'diamond.h',
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3E1C', %w(
  | unchanged empty file in nested sub-dir
  ) do
    @was_files = { 'w/e/r/diamond.h' => '' }
    @now_files = { 'w/e/r/diamond.h' => '' }
    assert_diff(
      type: :unchanged,
      old_filename: 'w/e/r/diamond.h',
      new_filename: 'w/e/r/diamond.h',
      line_counts: { added: 0, deleted: 0, same: 0 },
      lines: []
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3E1D', %w(
  | unchanged non-empty file
  ) do
    @was_files = { 'diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      type: :unchanged,
      old_filename: 'diamond.h',
      new_filename: 'diamond.h',
      line_counts: { added: 0, deleted: 0, same: 4 },
      lines: [
        same(1, 'a'),
        same(2, 'b'),
        same(3, 'c'),
        same(4, 'd')
      ]
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'Pf3E1E', %w(
  | unchanged non-empty file in nested sub-dir shows as all lines same
  ) do
    @was_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    @now_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    assert_diff(
      type: :unchanged,
      old_filename: 'r/t/y/diamond.h',
      new_filename: 'r/t/y/diamond.h',
      line_counts: { added: 0, deleted: 0, same: 4 },
      lines: [
        same(1, 'a'),
        same(2, 'bb'),
        same(3, 'c'),
        same(4, 'd')
      ]
    )
  end

  private

  def assert_diff(expected)
    assert_diff_lines(expected)
    expected.delete(:lines)
    assert_diff_summary(expected)
  end

  def assert_diff_lines(expected)
    diff = differ.diff_lines(was_files: @was_files, now_files: @now_files)
    assert diff.include?(expected), diff
  end

  def assert_diff_summary(expected)
    diff = differ.diff_summary(was_files: @was_files, now_files: @now_files)
    assert diff.include?(expected), diff
  end

  def deleted(number, line)
    { type: :deleted, number: number, line: line }
  end

  def same(number, line)
    { type: :same, number: number, line: line }
  end

  def added(number, line)
    { type: :added, number: number, line: line }
  end

  def section(index)
    { type: :section, index: index }
  end

end
