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
      set_nil(old_lines, old_start_line, chunk)
      section = [ { :type => :section, index:index } ]
      section += lines(old_start_line, chunk, :deleted)
      section += lines(new_start_line, chunk, :added)
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

  def set_nil(old_lines, start_line, chunk)
    chunk[:deleted].each_index do |index|
      old_lines[start_line + index - 1] = nil
    end
  end

  def lines(start_line, chunk, symbol)
    chunk[symbol].collect.with_index(start_line) do |line,number|
      { type:symbol, line:line, number:number }
    end
  end

end
