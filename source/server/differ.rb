require_relative 'git_differ'
require_relative 'git_diff_parser'

class Differ
  def initialize(externals)
    @externals = externals
  end

  def diff_lines(id:, was_index:, now_index:)
    diff_plus(id, was_index, now_index, lines: true)
  end

  def diff_summary(id:, was_index:, now_index:)
    diff_plus(id, was_index, now_index, lines: false)
  end

  private

  def diff_plus(id, was_index, now_index, options)
    was = saver.kata_event(id, was_index)
    now = saver.kata_event(id, now_index)
    was_files = files(was)
    now_files = files(now)
    diff_lines = GitDiffer.new(@externals).diff(id, was_files, now_files)
    diffs = GitDiffParser.new(diff_lines, options).parse_all
    fill_identical_renamed_files(diffs, now_files, options)
    diffs + unchanged_files(now_files, diffs, options)
  end

  def files(event)
    event['files'].transform_values do |file|
      file['content']
    end
  end

  def fill_identical_renamed_files(diffs, new_files, options)
    # Created entries for identical renames.
    # $ git diff ... prints no content in this case.
    diffs.each do |diff|
      next unless diff[:type] == :renamed && diff[:line_counts] == { same: 0, deleted: 0, added: 0 }

      filename = diff[:new_filename]
      lines = new_files[filename].split("\n")
      diff[:line_counts][:same] = lines.count
      diff[:lines] = same(lines) if options[:lines]
    end
  end

  def unchanged_files(new_files, changed, options)
    # Creates entries for unchanged files.
    all_filenames = new_files.keys
    changed_filenames = changed.collect { |file| file[:new_filename] }
    unchanged_filenames = all_filenames - changed_filenames
    unchanged_filenames.map do |filename|
      lines = new_files[filename].split("\n")
      diff = {
        type: :unchanged,
        old_filename: filename,
        new_filename: filename,
        line_counts: { added: 0, deleted: 0, same: lines.count }
      }
      diff[:lines] = same(lines) if options[:lines]
      diff
    end
  end

  def same(lines)
    lines.collect.with_index(1) do |line, number|
      { type: :same, line: line, number: number }
    end
  end

  def saver
    @externals.saver
  end
end
