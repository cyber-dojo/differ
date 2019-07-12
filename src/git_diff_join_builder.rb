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

  def git_diff_join_builder(diff, old_lines)

    diff[:chunks].each.with_index do |chunk,index|
      old_start_line = chunk[:old_start_line] # 1-based
      new_start_line = chunk[:new_start_line] # 1-based
      section = [ { :type => :section, index:index } ]
      section += deleted_lines(chunk, old_start_line, old_lines)
      section +=   added_lines(chunk, new_start_line)
      old_lines[old_start_line-1] = section
    end

    result = []
    old_lines.each.with_index(1) do |entry,index|
      if entry.is_a?(String)
        result += [ { :type => :same, line:entry, number:index } ]
      elsif entry.is_a?(Array)
        result += entry
      end
    end
    result
  end

  private

  def deleted_lines(chunk, old_start_line, old_lines)
    chunk[:deleted].collect.with_index(old_start_line) do |line,old_number|
      old_lines[old_number-1] = nil
      { :type => :deleted, line:line, number:old_number }
    end
  end

  def added_lines(chunk, new_start_line)
    chunk[:added].collect.with_index(new_start_line) do |line,new_number|
      { :type => :added, line:line, number:new_number }
    end
  end

end
