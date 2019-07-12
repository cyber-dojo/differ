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
      section = [ { type: :section, index: chunk_index } ]
      old_start_line = chunk[:old_start_line] # 1-based
      chunk[:deleted].each.with_index(old_start_line) do |line,number|
        old_lines[number-1] = nil
        section << { number:number, :type => :deleted, line:line }
      end
      new_start_line = chunk[:new_start_line] # 1-based
      chunk[:added].each.with_index(new_start_line) do |line,number|
        section << { number:number, :type => :added, line:line }
      end
      old_lines[old_start_line-1] = section
    end

    result = []
    old_lines.each.with_index(1) do |entry,index|
      if entry.is_a?(String)
        result += [ { number:index, type: :same, line:entry } ]
      elsif entry.is_a?(Array)
        result += entry
      end
    end
    result
  end

end
