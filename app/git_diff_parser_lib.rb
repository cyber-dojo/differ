# frozen_string_literal: true

module GitDiffParserLib

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

  def same?(line)
    line && line[0] === ' '
  end

  def deleted?(line)
    line && line[0] === '-'
  end

  def added?(line)
    line && line[0] === '+'
  end

end
