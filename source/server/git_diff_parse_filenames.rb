module GitDiffParseFilenames
  # The old and new filenames of one file's diff, from its header lines as
  # git diff --no-prefix --find-renames writes them: nil as the old filename
  # of a created file, and as the new filename of a deleted one.
  def parse_old_new_filenames(header)
    old_filename, new_filename = written_filenames(header)
    return [nil, new_filename] if header[1].start_with?('new file mode')
    return [old_filename, nil] if header[1].start_with?('deleted file mode')

    [old_filename, new_filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # The two filenames header names. A renamed file's come from its rename
  # from and rename to lines, which name one file each. Any other file's
  # come from its diff --git line, which names that one file twice. Its
  # diff --git line alone cannot give a renamed file's names: a name git
  # writes unquoted can hold a space, so where one name ends is unknown.
  def written_filenames(header)
    renames = header.grep(/\Arename (?:from|to) /)
    return twice_named(header[0]) if renames.empty?

    renames.map { |line| unquoted(line.split(' ', 3)[2]) }
  end

  # Example: ['sp ace.txt', 'sp ace.txt'] for "diff --git sp ace.txt sp ace.txt".
  # The one filename a diff --git line names twice, "diff --git X X", X
  # written as git writes it, as both the old and the new filename.
  def twice_named(first_line)
    both = first_line.delete_prefix('diff --git ')
    name = unquoted(both[0, both.size / 2])
    [name, name]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # The characters git writes as a C-style escape in a quoted filename,
  # by the letter after the backslash.
  ESCAPES = {
    'a' => "\a", 'b' => "\b", 't' => "\t", 'n' => "\n", 'v' => "\v",
    'f' => "\f", 'r' => "\r", '"' => '"', '\\' => '\\'
  }.freeze

  # Example: 'naïve.txt' for "\"na\\303\\257ve.txt\"".
  # A filename as git writes it: as it is, or, when it holds a character git
  # escapes, double-quoted, each such character a C-style escape and each
  # byte of a non-ASCII letter an octal escape, \ooo. An escape git never
  # writes raises KeyError.
  def unquoted(written)
    return written unless written.start_with?('"')

    bytes = written[1..-2].b.gsub(/\\([0-7]{3}|.)/n) do
      escape = ::Regexp.last_match(1)
      escape.size == 3 ? escape.to_i(8).chr : ESCAPES.fetch(escape)
    end
    bytes.force_encoding(Encoding::UTF_8)
  end
end
