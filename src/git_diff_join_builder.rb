# Combines diff and old_lines to build a data structure that
# containes a complete diff-view of a joined back up file;
#    the lines that were deleted
#    the lines that were added
#    the lines that were unchanged
#
# diff: created from GitDiffParser. The diff between two tags (run-tests) of a file.
# old_lines: an array containing the old content of the diffed file.
#
# Notes:
# o) a diff's hunk range specifies line numbers which are 1-based
# o) the array of lines is 0-based
# o) git_diff_join_builder() mutates its old_lines argument

module GitDiffJoinBuilder

  module_function

  def git_diff_join_builder(diff, old_lines)
    diff[:hunks].each.with_index do |hunk,index|
      old_start_line = hunk[:old_start_line]
      new_start_line = hunk[:new_start_line]
      section = [ { :type => :section, index:index } ]
      section += lines(old_start_line, hunk, :deleted)
      section += lines(new_start_line, hunk, :added)
      set_nil(old_lines, old_start_line-1, hunk[:deleted].size)
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

  def set_nil(old_lines, start_line, size)
    line_numbers = (start_line...start_line+size)
    line_numbers.each { |line_number| old_lines[line_number] = nil }
  end

  def lines(start_line, hunk, symbol)
    hunk[symbol].collect.with_index(start_line) do |line,number|
      { type:symbol, line:line, number:number }
    end
  end

end
