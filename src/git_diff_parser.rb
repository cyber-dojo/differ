# Assumes the --unified=0 option has been used
# so there are no context lines.

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    old_filename,new_filename = parse_old_new_filenames(parse_header)
             hunks: parse_hunks
  def parse_hunks
    hunks = []
    while hunk = parse_hunk
      hunks << hunk
    hunks
  def parse_hunk
      parse_newline_at_eof
      parse_newline_at_eof
      { old_start_line:range[1].to_i,
        new_start_line:range[3].to_i
      }
  def parse_header
    lines = [ line ]
    next_line # eat 'diff --git ...'
    while in_header?(line)
    lines
  def parse_old_new_filenames(header)
    old_filename,new_filename = old_new_filenames(header[0])
    if header[1].start_with?('deleted file mode')
    if header[1].start_with?('new file mode')
  private

  def in_header?(line)
    (!line.nil?) &&             # still more lines
    (line !~ /^diff --git/) &&  # not in next file
    (line !~ /^@@/)             # not in a range
  end

    [ cleaned(md[old_index]), cleaned(md[new_index]) ]
  def cleaned(filename)
    if quoted?(filename)
      filename = unquoted(filename)
    unescaped(filename)
  def quoted?(filename)
    filename[0].chr === '"'
  end
  def unquoted(filename)
    filename[1..-2]
  end

  def unescaped(str)
    # Avoiding eval.
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Notes
#--------------------------------------------------------------
# LINE: diff --git
# LINE: ...
# LINE: @@ -4,2 +4,1 @@ ...
# LINE: -CCC
# LINE: -DDD
# LINE: +EEE
# The line-range information is surrounded by @@'s'.
#   Eg @@ -4,2 +4,1 @@
# Which means
#   -4,2 for the   added lines [ 'CCC','DDD' ]
#   -4,1 for the deleted lines [ 'EEE' ]
# The line-range format is L,N where
#   L is the starting line number and
#   N is the number of lines.
# For -deleted lines, L,N refers to the original file.
# For   +added lines, L,N refers to the new file.
# The ,N is optional and if missing defaults to 1.
#   Eg -3 +5 is the same as -3,1 +5,1
# For a new/deleted file the range is -0,0
# Following the - lines and following the + lines
# there may be a single line
# LINE:\ No newline at end of file
# Eg
# LINE: diff --git
# LINE: ...
# LINE: @@ -4,2 +4,1 @@ ...
# LINE: -CCC
# LINE: -DDD
# LINE:\ No newline at end of file
# LINE: +EEE
# I wondered if the format of this was that the initial \
# means the line is a comment line and that there could be (are) other
# comments, but googling does not indicate this.
# https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html#Detailed%20Unified
# https://stackoverflow.com/questions/2529441