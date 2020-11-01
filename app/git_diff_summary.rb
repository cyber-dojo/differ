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
    diffs = GitDiffParser.new(diff_lines,:summary).parse_all
    diffs.each do |diff|
      if identical_rename?(diff)
        # $ git diff --unified=9999999 ... prints no content
        # for a 100% identical rename.
        same = new_files[diff[:new_filename]].lines.count
        diff[:line_counts][:same] = same
      end
    end
    diffs
  end

  def unchanged_summary(new_files, changed)
    unchanged_filenames(new_files.keys, new_filenames(changed)).map do |filename|
      {
        type: :unchanged,
        old_filename: filename,
        new_filename: filename,
        line_counts: {
          same: new_files[filename].lines.count,
          added: 0,
          deleted: 0
        }
      }
    end
  end

  def unchanged_filenames(new_filenames, changed_filenames)
    new_filenames - changed_filenames
  end

  def new_filenames(summary)
    summary.collect{ |file| file[:new_filename] }
  end

  def identical_rename?(diff)
    diff[:type] === :renamed && diff[:line_counts] === { same:0, deleted:0, added:0 }
  end

end
