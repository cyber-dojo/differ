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
    result.unshift([]) # make result 1-based to match range line-numbers

    diff[:hunks].each.with_index do |hunk,index|
      remove_deleted_lines(result, hunk)
      result[hunk[:old_start_line]] += make_section(hunk, index)
    end

    result.flatten!
    set_line_numbers(result)
    result
  end

  private

  def remove_deleted_lines(result, hunk)
    old_start_line = hunk[:old_start_line]
    old_end_line = old_start_line + hunk[:deleted].size
    (old_start_line...old_end_line).each do |line_number|
      result[line_number] = []
    end
  end

  def make_section(hunk, index)
    section = [ { :type => :section, index:index } ]
    section += lines(hunk, hunk[:old_start_line], :deleted)
    section += lines(hunk, hunk[:new_start_line], :added)
  end

  def lines(hunk, start_line, symbol)
    hunk[symbol].collect.with_index(start_line) do |line,number|
      { type:symbol, line:line, number:number }
    end
  end

  def set_line_numbers(result)
    # so they are based on new_files and not old_files
    line_number = 0
    result.each do |entry|
      if visible?(entry)
        line_number += 1
        entry[:number] = line_number
      end
    end
  end

  def visible?(entry)
    entry[:type] === :same || entry[:type] === :added
  end

end
