# frozen_string_literal: true
require_relative 'git_diff_lib' # all, line_split

module GitDiffLib # mix-in

  module_function

  def git_diff_lines(diffs, new_files)
    changed = changed_lines(diffs, new_files)
    unchanged = unchanged_lines(new_files, changed)
    changed + unchanged
  end

  private

  def changed_lines(diffs, new_files)
    diffs.each do |diff|
      if diff[:type] === :renamed && diff[:lines] === []
        filename = diff[:new_filename]
        file = new_files[filename]
        lines = same_lines(file)
        diff[:line_counts][:same] = lines.count
        diff[:lines] = lines
      end
    end
    diffs
  end

  def unchanged_lines(new_files, changed)
    all_filenames = new_files.keys
    changed_filenames = changed.collect{ |file| file[:new_filename] }
    unchanged_filenames = all_filenames - changed_filenames
    unchanged_filenames.map do |filename|
      file = new_files[filename]
      lines = same_lines(file)
      {         type: :unchanged,
        old_filename: filename,
        new_filename: filename,
         line_counts: { added:0, deleted:0, same:lines.count },
               lines: lines
      }
    end
  end

  def same_lines(file)
    if file === ''
      []
    else
      all(:same, file.split("\n"))
    end
  end

end