# frozen_string_literal: true
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  def git_diff_join(diff_lines, old_files, new_files)
    joined = {}
    filenames = new_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |diff|
      old_filename = diff[:old_filename]
      new_filename = diff[:new_filename]
      if deleted_file?(diff)
        joined[old_filename] = diff[:lines]
      elsif created_file?(diff)
        if empty?(diff)
          lines = [{ :type => :added, number:1, line:'' }]
        else
          lines = diff[:lines]
        end
        joined[new_filename] = lines
      elsif unchanged_rename?(old_filename, old_files, new_filename, new_files)
        lines = line_split(new_files[new_filename])
        joined[new_filename] = all(:same, lines)
      else # changed-file
        joined[new_filename] = diff[:lines]
      end
      filenames.delete(new_filename)
    end
    filenames.each do |unchanged_filename|
      lines = line_split(new_files[unchanged_filename])
      joined[unchanged_filename] = all(:same, lines)
    end
    joined
  end

end
