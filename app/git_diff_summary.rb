# frozen_string_literal: true
require_relative 'git_diff_lib'
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(diff_lines, new_files)
    changed = changed_summary(diff_lines, new_files)
    unchanged = unchanged_summary(new_files, changed)
    changed + unchanged
  end

  private

  def changed_summary(diff_lines, new_files)
    GitDiffParser.new(diff_lines,:summary).parse_all.map do |diff|
      same = count_lines_same(diff, new_files)
      added = diff[:line_counts][:added]
      deleted = diff[:line_counts][:deleted]
      one_file(same, added, deleted, diff)
    end
  end

  def unchanged_summary(new_files, changed)
    unchanged_filenames(new_files.keys, new_filenames(changed)).map do |filename|
      same = new_files[filename].lines.count
      one_file(same, 0, 0, {
        type: :unchanged,
        old_filename: filename,
        new_filename: filename
      })
    end
  end

  def unchanged_filenames(new_filenames, changed_filenames)
    new_filenames - changed_filenames
  end

  def new_filenames(summary)
    summary.collect{ |file| file['new_filename'] }
  end

  def one_file(same, added, deleted, diff)
    {
      'type' => diff[:type],
      'old_filename' => diff[:old_filename],
      'new_filename' => diff[:new_filename],
      'line_counts' => {
        'same'    => same,
        'added'   => added,
        'deleted' => deleted
      }
    }
  end

  def count_lines_same(diff, new_files)
    # $ git diff --unified=9999999 ... prints no content for a 100% identical rename.
    if diff[:type] === :renamed && zero?(diff[:line_counts])
      new_files[diff[:new_filename]].lines.count
    else
      diff[:line_counts][:same]
    end
  end

  def zero?(counts)
    counts[:same] === 0 && counts[:deleted] === 0 && counts[:added] === 0
  end

end
