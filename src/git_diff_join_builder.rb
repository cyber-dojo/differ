# Combines diff and lines to build a data structure that
# containes a complete diff-view of a joined back up file;
#    the lines that were deleted
#    the lines that were added
#    the lines that were unchanged
#
# diff: created from GitDiffParser. The diff between two tags (run-tests) of a file.
# lines: an array containing the current content of the diffed file.

module GitDiffJoinBuilder # mix-in

  module_function

  def git_diff_join_builder(diff, old_lines, new_lines)

    diff[:chunks].each_with_index do |chunk,chunk_index|
      section = [
        { :type => :section, :index => chunk_index }
      ]
      o = chunk[:old][:start_line] # 1-based
      chunk[:deleted].each_with_index do |line,index|
        line_number = o + index
        old_lines[line_number-1] = nil
        section << { number:line_number, type: :deleted, line:line }
      end
      n = chunk[:new][:start_line] # 1-based
      chunk[:added].each_with_index do |line,index|
        line_number = n + index
        line = new_lines[line_number-1]
        section << { number:line_number, type: :added, line:line }
      end
      old_lines[o-1] = section
    end

    result = []
    old_lines.each_with_index do |entry,index|
      if entry.is_a?(String)
        result += [ { number:index+1, type: :same, line:entry } ]
      elsif entry.is_a?(Array)
        result += entry
      end
    end
    result
  end

end
