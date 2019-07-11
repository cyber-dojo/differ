require_relative 'line_splitter'

class GitDiffParser # Parses the output of 'git diff' command.

  def initialize(diff_text)
    @lines = LineSplitter.line_split(diff_text)
    @n = 0
  end

  attr_reader :lines, :n

  def parse_all
    all = {}
    while /^diff --git/.match(line) do
      one = parse_one
      name = one[:now_filename] || one[:was_filename]
      all[name] = one
    end
    all
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_one
    prefix_lines = parse_prefix_lines
    was_filename,now_filename = parse_was_now_filenames(prefix_lines)
    chunks = parse_chunk_all
    {
      prefix_lines: prefix_lines,
      was_filename: was_filename,
      now_filename: now_filename,
            chunks: chunks
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_chunk_all
    chunks = []
    while chunk = parse_chunk_one
      chunks << chunk
    end
    chunks
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_chunk_one
    if range = parse_range
      {        range: range,
        before_lines: parse_common_lines,
            sections: parse_sections
      }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_range
    re = /^@@ -(\d+),?(\d+)? \+(\d+),?(\d+)? @@.*/
    if range = re.match(line)
      next_line
      was = { start_line: range[1].to_i,
                    size: size_or_default(range[2])
            }
      now = { start_line: range[3].to_i,
                    size: size_or_default(range[4])
            }
      { was: was, now: now }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def size_or_default(size)
    size ? size.to_i : 1
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_sections
    parse_newline_at_eof
    sections = []
    while /^[\+\- ]/.match(line)
      deleted_lines = parse_lines(/^\-(.*)/)
      parse_newline_at_eof

      added_lines = parse_lines(/^\+(.*)/)
      parse_newline_at_eof

      after_lines = parse_common_lines
      parse_newline_at_eof

      sections << {
        deleted_lines: deleted_lines,
          added_lines: added_lines,
          after_lines: after_lines
      }
    end
    sections
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_prefix_lines
    line0 = line
    next_line

    lines = []
    while (!line.nil?) &&             # still more lines
          (line !~ /^diff --git/) &&  # not in next file
          (line !~ /^[-]/) &&         # not in --- filename
          (line !~ /^[+]/)            # not in +++ filename
      lines << line
      next_line
    end
    [line0] + lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_common_lines
    parse_lines(%r|^ (.*)|)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_was_now_filenames(prefix)
    next_line if %r|^\-\-\- (.*)|.match(line)
    next_line if %r|^\+\+\+ (.*)|.match(line)
    was,now = get_was_now_filenames(prefix[0])
    now = nil if prefix[1].start_with?('deleted file mode')
    was = nil if prefix[1].start_with?('new file mode')
    [was, now]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def get_was_now_filenames(first_line)
    return was_now_match(:uf, :uf, first_line) ||
           was_now_match(:uf, :qf, first_line) ||
           was_now_match(:qf, :qf, first_line) ||
           was_now_match(:qf, :uf, first_line)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def was_now_match(was, now, first_line)
    filename = {
      :qf => '("(\\"|[^"])+")', # quoted,   eg "b/emb ed\"ed.h"
      :uf => '([^ ]*)',         # unquoted, eg a/plain
    }
    md = %r[^diff --git #{filename[was]} #{filename[now]}$].match(first_line)
    return nil if md.nil?
    was_index = 1
    now_index = (was === :uf) ? 2 : 3
    return [ unescaped(md[was_index]), unescaped(md[now_index]) ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def unescaped(filename)
    # filename[1..-2] to lose the opening and closing "
    # then unescape without using eval
    filename = unescape(filename[1..-2]) if filename[0].chr === '"'
    # drop leading a/ or b/
    filename[2..-1]
    # Note: there is a [git diff] option --no-prefix which removes
    # the leading a/ b/ from the output. Using that option would
    # require removing a/ b/ from a lot of test code.
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def unescape(str)
    # http://stackoverflow.com/questions/8639642/best-way-to-escape-and-unescape-strings-in-ruby
    unescapes = {
        "\\\\" => "\x5c",
        '"'    => "\x22",
        "'"    => "\x27"
    }
    str.gsub(/\\(?:([#{unescapes.keys.join}]))/) {
      $1 === '\\' ? '\\' : unescapes[$1]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_newline_at_eof
    next_line if /^\\ No newline at end of file/.match(line)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_lines(re)
    lines = []
    while md = re.match(line)
      lines << md[1]
      next_line
    end
    lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def next_line
    @n += 1
  end

  def line
    @lines[@n]
  end

end

#--------------------------------------------------------------
# Git diff format notes
#
# LINE: --- a/gapper.rb
#
#  The original file is preceded by ---
#  If this is a new file this is --- /dev/null
#
# LINE: +++ b/gapper.rb
#
#  The new file is preceded by +++
#  If this is a deleted file this is +++ /dev/null
#
# LINE: @@ -4,7 +4,8 @@ def time_gaps(from, to, seconds_per_gap)
#
#  Following this is a change chunk containing the line differences.
#  A chunk begins with range information. The range information
#  is surrounded by double-at signs.
#    So in this example its @@ -4,7 +4,8 @@
#  The chunk range information contains two chunk ranges.
#  Each chunk range is of the format L,S where
#  L is the starting line number and
#  S is the number of lines the change chunk applies to for
#  each respective file.
#  The ,S is optional and if missing indicates a chunk size of 1.
#  So -3 is the same as -3,1 and -1 is the same as -1,1
#
#  The range for the chunk of the original file is preceded by a
#  minus symbol.
#    So in this example its -4,7
#  If this is a new file (--- /dev/null) this is -0,0
#
#  The range for the chunk of the new file is preceded by a
#  plus symbol.
#    So in this example its +4,8
#  If this is a deleted file (+++ /dev/null) this is -0,0
#
# LINE:   (0..n+1).collect {|i| from + i * seconds_per_gap }
# LINE: end
# LINE:
#
#  Following this, optionally, are the unchanged, contextual lines,
#  each preceded by a space character.
#  These are lines that are common to both the old file and the new file.
#  So here there are three lines, (the third line is a newline)
#  So the -4,7 tells us that these three common lines are lines
#  4,5,6 in the original file.
#
# LINE:-def full_gapper(all_incs, gaps)
#
#  Following this, optionally, are the deleted lines, each preceded by a
#  minus sign. This is the first deleted line so it was line 7 (one after 6)
#  If there were subsequent deleted lines they would having incrementing line
#  numbers, 8,9 etc.
#
# LINE:\ No newline at end of file
#
#  Following this, optionally, is a single line starting with a \ character
#  as above. I wondered if the format of this was that the initial \
#  means the line is a comment line and that there could be (are) other
#  comments, but googling does not indicate this.
#
# LINE:+def full_gapper(all_incs, created, seconds_per_gap)
# LINE:+  gaps = time_gaps(created, latest(all_incs), seconds_per_gap)
#
#  Following this, optionally, are the added lines, each preceeded by a
#  + sign. So the +4,8 and the 3 common lines tells us that the first +
#  line is line 7 in the new file, and the second + line is line 8 in
#  the new file.
#
# LINE:\ No newline at end of file
#
#  Following this, optionally, is a single line starting with a \ character
#  as above.
#
# http://www.artima.com/weblogs/viewpost.jsp?thread=164293
# Is a blog entry by Guido van Rossum.
# He says that in L,S the ,S can be omitted if the chunk size
# S is 1. So -3 is the same as -3,1
#
#--------------------------------------------------------------
# http://en.wikipedia.org/wiki/Diff
# http://www.chemie.fu-berlin.de/chemnet/use/info/diff/diff_3.html
