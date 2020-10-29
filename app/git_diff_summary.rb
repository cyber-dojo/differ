# frozen_string_literal: true
require_relative 'git_diff_lib'
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  module_function

=begin
  def XX_git_diff_summary(git_diff, was_files, now_files)
    diff = git_diff_summary_data(git_diff, was_files, now_files)
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
=end

  def git_diff_summary(diff_lines, old_files, new_files)
    diffs = []
    GitDiffParser.new(diff_lines).parse_all.each do |diff|
      old_filename = diff[:old_filename]
      new_filename = diff[:new_filename]
      d = {
        'old_filename' => old_filename,
        'new_filename' => new_filename
      }

      if deleted_file?(diff)
        counts = line_counts(diff[:lines])
        if counts['added'] + counts['deleted'] > 0
          #tip_data[old_filename] = counts
          d['line_counts'] = counts
        end
        # TODO: if deleted file has no changes
        # do I need old_files to get the lines to know
        # how many unchanged lines there were? Or is that
        # in the diff itself?
      elsif new_file?(diff)
        if empty?(diff)
          lines = [{ :type => :added, number:1, line:'' }]
        else
          lines = diff[:lines]
        end
        d['line_counts'] = line_counts(lines)
      elsif !unchanged_rename?(old_filename, old_files, new_filename, new_files)
        # Note: a 100% identical file rename
        # gives a diff without info on the file's lines.
        # To retrieve the content we need the new_files (or old_files)
        d['line_counts'] = line_counts(diff[:lines]) # changed-file
      end
      diffs << d
    end
    diffs
  end

  def line_counts(lines)
    {
      'added'   => lines.count{ |line| line[:type] === :added   },
      'deleted' => lines.count{ |line| line[:type] === :deleted },
      'same' => 0
    }
  end

end
