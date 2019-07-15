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
      deleted_lines = lines(:deleted, hunk[:deleted], hunk[:old_start_line])
        added_lines = lines(:added  , hunk[:added  ], hunk[:new_start_line])

      if added_lines.empty?                            # @@ ... -3,0 @@
        range = (line_number..hunk[:new_start_line])   # => (LN..3)
      else                                             # @@ ... -4,2 @@
        range = (line_number..hunk[:new_start_line]-1) # => (LN..3)
      end

      same_lines = lines(:same, new_lines[range], range.min)

      joined += same_lines
      joined += section
      joined += deleted_lines
      joined += added_lines

      line_number += same_lines.size + added_lines.size
    end

    range = (line_number..new_lines.size)
    same_lines = lines(:same, new_lines[range], range.min)
    joined += same_lines
  end

  def lines(type, from, lo)
    from.collect.with_index(lo) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
