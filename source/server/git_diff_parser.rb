require_relative 'git_diff_parse_filenames'

class GitDiffParser
  # Parses the output of 'git diff' command.
  # Assumes the --unified=99999999999 option has been used
  # so there is always a single @@ range and all context lines.

  # The line git writes after a line with no newline at its end. It changes
  # nothing a diff reports, so it is dropped as the diff is read.
  NO_NEWLINE_AT_EOF = '\ No newline at end of file'.freeze

  def initialize(diff_text, options)
    @lines = diff_text.split("\n") - [NO_NEWLINE_AT_EOF]
    @n = 0 # index into @lines
    @options = options
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_all
    # Each file's diff, in the order git wrote them.
    all = []
    all << parse_one while line
    all
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_one
    # The next file's diff: its type, filenames and line counts, and, with
    # the lines option, its lines. The counts are counted from the lines.
    old_filename, new_filename = parse_old_new_filenames(parse_header)
    parse_range
    lines = parse_lines
    one = {
      type: file_type(old_filename, new_filename),
      new_filename: new_filename,
      old_filename: old_filename,
      line_counts: counts_of(lines)
    }
    one[:lines] = lines if @options[:lines]
    one
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_header
    # The next file's header lines: its diff --git line and those after it,
    # up to its @@ range, or the next file's diff --git line.
    lines = [line]
    next_line # eat 'diff --git ...'
    while in_header?(line)
      lines << line
      next_line
    end
    lines
  end

  private

  include GitDiffParseFilenames

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

  def in_header?(line)
    line &&                               # still more lines
      !line.start_with?('diff --git') &&  # not in next file
      !line.start_with?('@@') # not in a range
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_range
    return unless line&.start_with?('@@')

    next_line
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_lines
    # One file's lines, up to the next file's diff --git line: runs of same
    # lines, each change between them a section, its deleted lines then its
    # added lines. Each line is numbered in the file it is in: a deleted line
    # in the old file, a same or an added line in the new one.
    @numbers = { old: 1, new: 1 }
    @section = 0
    lines = []
    lines.concat(parse_run) while line && !line.start_with?('diff --git')
    lines
  end

  def parse_run
    # One run of a file's lines: its same lines, then its change. A line that
    # is neither raises, so no line can stall the parse.
    run = lines_of(:same) + change
    raise "unparsed git diff line: #{line}" if run.empty?

    run
  end

  def change
    # A section marker, then its deleted lines and its added lines; none
    # where the next line is no deleted or added line.
    return [] unless line&.start_with?(PREFIXES[:deleted], PREFIXES[:added])

    section = { type: :section, index: @section }
    @section += 1
    [section, *lines_of(:deleted), *lines_of(:added)]
  end

  # How git marks each kind of line; the file whose numbering each is
  # numbered in; and the files each kind of line is in, whose numbering it
  # moves on: a same line is in both.
  PREFIXES = { same: ' ', deleted: '-', added: '+' }.freeze
  NUMBERED_IN = { same: :new, deleted: :old, added: :new }.freeze
  IN_FILES = { same: %i[old new], deleted: %i[old], added: %i[new] }.freeze

  def lines_of(type)
    # The run of consecutive lines of type from the current line, each
    # numbered.
    run = []
    while line&.start_with?(PREFIXES[type])
      run << source_line(type, line, @numbers[NUMBERED_IN[type]])
      IN_FILES[type].each { |file| @numbers[file] += 1 }
    end
    run
  end

  def counts_of(lines)
    # How many of lines were added, deleted and the same.
    types = lines.map { |entry| entry[:type] }.tally
    { added: types.fetch(:added, 0), deleted: types.fetch(:deleted, 0), same: types.fetch(:same, 0) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def source_line(type, line, number)
    next_line
    { type: type, line: line[1..], number: number }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def line
    @lines[@n]
  end

  def next_line
    @n += 1
  end
end
