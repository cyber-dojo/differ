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

module GitDiffJoinBuilder

  module_function

  def git_diff_join_builder(diff, old_lines)
    result = old_lines.collect.with_index(1) do |line,number|
      [ { :type => :same, line:line, number:number } ]
    end
    result.unshift([])

    diff[:hunks].each.with_index do |hunk,index|
      old_start_line = hunk[:old_start_line]
      new_start_line = hunk[:new_start_line]
      section = [ { :type => :section, index:index } ]
      section += lines(hunk, old_start_line, :deleted)
      section += lines(hunk, new_start_line, :added)
      old_end_line = old_start_line + hunk[:deleted].size
      (old_start_line...old_end_line).each do |number|
        result[number] = []
      end
      result[old_start_line] += section
    end

    result.flatten!
    line_number = 0
    result.each do |entry|
      if entry[:type] === :same || entry[:type] === :added
        line_number += 1
        entry[:number] = line_number
      end
    end

    result
  end

  private

  def lines(hunk, start_line, symbol)
    hunk[symbol].collect.with_index(start_line) do |line,number|
      { type:symbol, line:line, number:number }
    end
  end

end
