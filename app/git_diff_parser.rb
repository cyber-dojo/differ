# frozen_string_literal: true

class GitDiffParser

  # Parses the output of 'git diff' command.
  # Assumes the --unified=99999999999 option has been used
  # so there is always a single @@ range and all context lines

  def initialize(diff_text, mode = :lines)
    @lines = diff_text.split("\n")
    @n = 0
    @mode = mode
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_all
    all = []
    while line && line.start_with?('diff --git') do
      all << parse_one
    end
    all
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_one
    old_filename,new_filename = parse_old_new_filenames(parse_header)
    parse_range
    one = {
              type: file_type(old_filename, new_filename),
      new_filename: new_filename,
      old_filename: old_filename,
    }
    if @mode === :lines
      parse_lines_into(one)
    else # :summary
      parse_counts_into(one)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def file_type(old_filename, new_filename)
    if old_filename.nil?
      :created
    elsif new_filename.nil?
      :deleted
    elsif old_filename != new_filename
      :renamed
    else
      :changed
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_lines_into(one)
    one[:lines] = parse_lines
    one
  end

  def parse_lines
    lines = []
    index,old_number,new_number = 0,1,1
    while line && !line.start_with?('diff --git') do
      while same?(line) do
        lines << src(:same, line, new_number)
        old_number += 1
        new_number += 1
      end
      if deleted?(line) || added?(line)
        lines << { :type => :section, index:index }
        index += 1
      end
      while deleted?(line) do
        lines << src(:deleted, line, old_number)
        old_number += 1
      end
      parse_newline_at_eof
      while added?(line) do
        lines << src(:added, line, new_number)
        new_number += 1
      end
      parse_newline_at_eof
    end
    lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_counts_into(one)
    one[:line_counts] = parse_counts
    one
  end

  def parse_counts
    same,deleted,added = 0,0,0
    while line && !line.start_with?('diff --git') do
      while same?(line) do
        same += 1
        next_line
      end
      while deleted?(line) do
        deleted += 1
        next_line
      end
      parse_newline_at_eof
      while added?(line) do
        added += 1
        next_line
      end
      parse_newline_at_eof
    end
    { same:same, deleted:deleted, added:added }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_header
    lines = [ line ]
    next_line # eat 'diff --git ...'
    while in_header?(line)
      lines << line
      next_line
    end
    lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_old_new_filenames(header)
    old_filename,new_filename = old_new_filenames(header[0])
    if header[1].start_with?('deleted file mode')
      new_filename = nil
    end
    if header[1].start_with?('new file mode')
      old_filename = nil
    end
    [old_filename, new_filename]
  end

  private

  def in_header?(line)
    line &&                             # still more lines
    !line.start_with?('diff --git') &&  # not in next file
    !line.start_with?('@@')             # not in a range
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def old_new_filenames(first_line)
    return old_new_filename_match(:uf, :uf, first_line) ||
           old_new_filename_match(:uf, :qf, first_line) ||
           old_new_filename_match(:qf, :qf, first_line) ||
           old_new_filename_match(:qf, :uf, first_line)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  FILENAME_REGEXS = {
    :qf => '("(\\"|[^"])+")', # quoted-filename,   eg "b/emb ed\"ed.h"
    :uf => '([^ ]*)',         # unquoted-filename, eg a/plain
  }

  def old_new_filename_match(q1, q2, first_line)
    md = %r[^diff --git #{FILENAME_REGEXS[q1]} #{FILENAME_REGEXS[q2]}$].match(first_line)
    if md.nil?
      return nil
    end
    old_index = 1
    if q1 === :uf
      new_index = 2
    else
      new_index = 3
    end
    [ cleaned(md[old_index]), cleaned(md[new_index]) ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cleaned(filename)
    if quoted?(filename)
      filename = unquoted(filename)
    end
    unescaped(filename)
  end

  def quoted?(filename)
    filename[0].chr === '"'
  end

  def unquoted(filename)
    filename[1..-2]
  end

  def unescaped(str)
    # Avoiding eval.
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

  def parse_range
    if line && line.start_with?('@@')
      next_line
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def same?(line)
    line && line[0] === ' '
  end

  def deleted?(line)
    line && line[0] === '-'
  end

  def added?(line)
    line && line[0] === '+'
  end

  def src(type, line, number)
    next_line
    { type:type, line:line[1..-1], number:number }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_newline_at_eof
    if /^\\ No newline at end of file/.match(line)
      next_line
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def line
    @lines[@n]
  end

  def next_line
    @n += 1
  end

end

#--------------------------------------------------------------
# Notes (for when not using git diff --unified=VERY_LARGE)
#--------------------------------------------------------------
# LINE: diff --git
# LINE: ...
# LINE: @@ -4,2 +4,1 @@ ...
# LINE: -CCC
# LINE: -DDD
# LINE: +EEE
#
# The line-range information is surrounded by @@'s'.
#   Eg @@ -4,2 +4,1 @@
# Which means
#   -4,2 for the   added lines [ 'CCC','DDD' ]
#   -4,1 for the deleted lines [ 'EEE' ]
#
# The line-range format is L,N where
#   L is the starting line number and
#   N is the number of lines.
#
# For -deleted lines, L,N refers to the original file.
# For   +added lines, L,N refers to the new file.
#
# The ,N is optional and if missing defaults to 1.
#   Eg -3 +5 is the same as -3,1 +5,1
#
# For a new/deleted file the range is -0,0
#
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
# LINE:\ No newline at end of file
#
# I wondered if the format of this was that the initial \
# means the line is a comment line and that there could be (are) other
# comments, but googling does not indicate this.
#--------------------------------------------------------------
# https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html#Detailed%20Unified
# https://stackoverflow.com/questions/2529441
# http://en.wikipedia.org/wiki/Diff
# http://www.chemie.fu-berlin.de/chemnet/use/info/diff/diff_3.html
