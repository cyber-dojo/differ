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
      if diff[:lines] === []
        if diff[:type] === :renamed
          filename = diff[:new_filename]
          file = new_files[filename]
          lines = all(:same, file_lines(file))
        elsif diff[:type] === :deleted
          lines = [ { type: :deleted, number:1, line:''} ]
        elsif diff[:type] === :created
          lines = [ { type: :added, number:1, line:'' } ]
        end
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
      {         type: :unchanged,
        old_filename: filename,
        new_filename: filename,
         lines: all(:same, line_split(new_files[filename]))
      }
    end
  end

  def file_lines(file)
    if file === ''
      ['']
    else
      file.split("\n")
    end
  end

end
