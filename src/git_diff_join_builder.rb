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

require 'json'

module GitDiffJoinBuilder

  module_function

  def git_diff_join_builder(diff, new_lines)
    joined = []
    new_lines.unshift(nil) # make it 1-based
    line_number = 1
    diff[:hunks].each.with_index(0) do |hunk,index|
      section = [ { :type => :section, index:index } ]
      deleted_lines = hunk_lines(hunk, :deleted, hunk[:old_start_line])
        added_lines = hunk_lines(hunk, :added,   hunk[:new_start_line])

      if added_lines.empty?
        range = (line_number...hunk[:new_start_line]+1)
      else
        range = (line_number...hunk[:new_start_line])
      end

      lines = same_lines(new_lines, range)

      joined += lines
      joined += section
      joined += deleted_lines
      joined += added_lines

      line_number += lines.size + added_lines.size
    end

    lines = same_lines(new_lines, (line_number...new_lines.size))
    joined += lines
  end

  def same_lines(src, range)
    all_lines(:same, src[range], range.min)
  end

  def hunk_lines(hunk, symbol, lo)
    all_lines(symbol, hunk[symbol], lo)
  end

  def all_lines(type, from, lo)
    from.collect.with_index(lo) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
