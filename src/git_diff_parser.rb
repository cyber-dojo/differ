# Parses the output of 'git diff' command.
class GitDiffParser
    all = []
      all << parse_one
    old_filename,new_filename = parse_old_new_filenames(parse_prefix_lines)
      new_filename: new_filename,
      old_filename: old_filename,
            chunks: parse_chunks
  def parse_chunks
    while chunk = parse_chunk
  def parse_chunk
      range[:deleted] = parse_lines(/^\-(.*)/)
      range[:added  ] = parse_lines(/^\+(.*)/)
      range
    re = /^@@ -(\d+)(,\d+)? \+(\d+)(,\d+)? @@.*/
      next_line
      { old_start_line:range[1].to_i, new_start_line:range[3].to_i }
    next_line
      next_line
  def parse_old_new_filenames(prefix)
    next_line if %r|^\-\-\- (.*)|.match(line)
    next_line if %r|^\+\+\+ (.*)|.match(line)
    old_filename,new_filename = old_new_filenames(prefix[0])
    new_filename = nil if prefix[1].start_with?('deleted file mode')
    old_filename = nil if prefix[1].start_with?('new file mode')
    [old_filename, new_filename]
  def old_new_filenames(first_line)
    return old_new_filename_match(:uf, :uf, first_line) ||
           old_new_filename_match(:uf, :qf, first_line) ||
           old_new_filename_match(:qf, :qf, first_line) ||
           old_new_filename_match(:qf, :uf, first_line)
  FILENAME_REGEXS = {
    :qf => '("(\\"|[^"])+")', # quoted-filename,   eg "b/emb ed\"ed.h"
    :uf => '([^ ]*)',         # unquoted-filename, eg a/plain
  }
  def old_new_filename_match(q1, q2, first_line)
    md = %r[^diff --git #{FILENAME_REGEXS[q1]} #{FILENAME_REGEXS[q2]}$].match(first_line)
    old_index = 1
    new_index = (q1 === :uf) ? 2 : 3
    [ unescaped(md[old_index]), unescaped(md[new_index]) ]
      next_line
    parse_newline_at_eof
  def parse_newline_at_eof
    next_line if /^\\ No newline at end of file/.match(line)
  end

  private

  def next_line
    @n += 1
  end

#    So in this example its @@ -4,7 +15,8 @@
#  The chunk range information contains at most two chunk ranges.
#  @@ -4,7 +15,8 is for added lines (-4,7) and deleted lines (+5,8)
#  @@ -4,7 @@ is for deleted lines only.
#  @@ +15,8 @@ is for added lines only.
#
#  For -deleted lines, L,S refers to the original file.
#  For   +added lines, L,S refers to the new file.
#  The ,S is optional and if missing indicates a chunk size of 1.
#  So -3 is the same as -3,1
#  And -1 is the same as -1,1
#  And -3 +5 is the same as -3,1 +5,1
#  If this is a     new file (--- /dev/null) the range is -0,0
#  If this is a deleted file (+++ /dev/null) the range is -0,0