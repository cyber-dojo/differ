# frozen_string_literal: true
require_relative 'git_diff_lib'

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(git_diff, was_files, now_files)
    diff = git_diff_tip_data(git_diff, was_files, now_files)
    result = []
    diff.keys.each do |filename|
      result << {
        "old_filename" => filename,
        "new_filename" => filename,
        "line_counts" => {
          "deleted" => diff[filename]['deleted'],
            "added" => diff[filename]['added'],
             "same" => 0
        }
      }
    end
    result
  end

end
