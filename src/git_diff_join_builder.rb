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
      dputs "at top: hunk==#{JSON.pretty_generate(hunk)}"
      dputs "at top: line_number==#{line_number}"

      section = [ { :type => :section, index:index } ]
      deleted_lines = hunk_lines(hunk, :deleted, hunk[:old_start_line])
      added_lines = hunk_lines(hunk, :added,   hunk[:new_start_line])

      end_line_number = hunk[:new_start_line]
      if added_lines.empty?
        end_line_number += 1
      end

      dputs "top-same-lines: line_number=#{line_number}"
      dputs "top-same-lines: end_line_number=#{end_line_number}"

      lines = same_lines(new_lines, line_number, end_line_number)
      dputs "top-same-lines: #{lines}"

      joined += lines
      show(joined,'After += top-same-lines')
      joined += section
      show(joined,'After += section')
      joined += deleted_lines
      show(joined,'After += deleted lines')
      joined += added_lines
      show(joined,'After += added lines')

      line_number += lines.size
      line_number += added_lines.size
    end

    lines = same_lines(new_lines, line_number, new_lines.size) # common end-lines
    joined += lines
    show(joined,'After += end-same-lines')
    joined
  end

  def same_lines(src, lo, hi)
    dputs "same_lines:lo=#{lo}"
    dputs "same_lines:hi=#{hi}"
    lines = src[lo...hi].collect.with_index(lo) do |line,number|
      entry(:same,line,number)
    end
    dputs "same_lines:size=#{lines.size}"
    lines
  end

  def hunk_lines(hunk, symbol, lo)
    hunk[symbol].collect.with_index(lo) do |line,number|
      entry(symbol,line,number)
    end
  end

  def entry(type, line, number)
    { type:type, line:line, number:number }
  end

  def show(joined,msg)
    dputs "#{msg}-----------------"
    joined.each.with_index(0) do |line,index|
      dputs "#{index}:#{line}"
    end
  end

  def dputs(fmt, *args)
    #puts(fmt, *args)
  end

end
