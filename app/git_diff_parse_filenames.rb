# frozen_string_literal: true
module GitDiffParseFilenames
    old_filename, new_filename = old_new_filenames(header[0])
    new_filename = nil if header[1].start_with?('deleted file mode')
    old_filename = nil if header[1].start_with?('new file mode')
    old_new_filename_match(:uf, :uf, first_line) ||
      old_new_filename_match(:uf, :qf, first_line) ||
      old_new_filename_match(:qf, :qf, first_line) ||
      old_new_filename_match(:qf, :uf, first_line)
    qf: '("(\\"|[^"])+")', # quoted-filename,   eg "b/emb ed\"ed.h"
    uf: '([^ ]*)' # unquoted-filename, eg a/plain
  }.freeze

  def old_new_filename_match(quote1, quote2, first_line)
    md = /^diff --git #{FILENAME_REGEXS[quote1]} #{FILENAME_REGEXS[quote2]}$/.match(first_line)
    return nil if md.nil?
    new_index = if quote1 == :uf
                  2
                else
                  3
                end
    [cleaned(md[old_index]), cleaned(md[new_index])]
    filename = unquoted(filename) if quoted?(filename)
    filename[0].chr == '"'
      '\\\\' => "\x5c",
      '"' => "\x22",
      "'" => "\x27"
    str.gsub(/\\(?:([#{unescapes.keys.join}]))/) do
      ::Regexp.last_match(1) == '\\' ? '\\' : unescapes[::Regexp.last_match(1)]
    end