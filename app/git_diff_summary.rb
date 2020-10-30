# frozen_string_literal: true
require_relative 'git_diff_lib'
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(diff_lines, new_files)
    summary = GitDiffParser.new(diff_lines).parse_all.map do |diff|
      diff_type = type_of(diff)
      {
        'type' => diff_type,
        'old_filename' => diff[:old_filename],
        'new_filename' => diff[:new_filename],
        'line_counts' => {
          'same'    => count_lines_same(diff, diff_type, new_files),
          'added'   => count_lines(:added, diff),
          'deleted' => count_lines(:deleted, diff)
        }
      }
    end
    changed_filenames = summary.collect{ |file| file['new_filename'] }
    unchanged_filenames = new_files.keys - changed_filenames
    unchanged_filenames.each do |filename|
      summary << {
        'type' => :unchanged,
        'old_filename' => filename,
        'new_filename' => filename,
        'line_counts' => {
          'same'    => new_files[filename].lines.count,
          'added'   => 0,
          'deleted' => 0
        }
      }
    end
    summary
  end

  private

  def count_lines_same(diff, diff_type, new_files)
    # $ git diff --unified=9999999 ...
    # prints no content for a 100% identical rename.
    if diff_type === :renamed && empty?(diff)
      new_files[diff[:new_filename]].lines.count
    else
      count_lines(:same, diff)
    end
  end

  def count_lines(line_type, diff)
    diff[:lines].count{ |line| line[:type] === line_type }
  end

end
