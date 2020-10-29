# frozen_string_literal: true
require_relative 'git_diff_lib'
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(diff_lines, new_files)
    GitDiffParser.new(diff_lines).parse_all.map do |diff|
      {
        'old_filename' => diff[:old_filename],
        'new_filename' => diff[:new_filename],
        'line_counts' => line_counts(diff, new_files)
      }
    end
  end

  def line_counts(diff, new_files)
    {
      'added'   => diff[:lines].count{ |line| line[:type] === :added   },
      'deleted' => diff[:lines].count{ |line| line[:type] === :deleted },
      'same' => count_same_lines(diff, new_files)
    }
  end

  def count_same_lines(diff, new_files)
    if identical_rename?(diff)
      new_files[diff[:new_filename]].lines.count
    else
      diff[:lines].count{ |line| line[:type] === :same }
    end
  end

  def identical_rename?(diff)
    renamed_file?(diff) && empty?(diff)
  end

  def renamed_file?(diff)
    [ !new_file?(diff),
      !deleted_file?(diff),
      diff[:new_filename] != diff[:old_filename]
    ].all?
  end

end
