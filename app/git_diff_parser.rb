# frozen_string_literal: true
require_relative 'git_diff_parse_filenames'

class GitDiffParser

  # Parses the output of 'git diff' command.
  # Assumes the --unified=99999999999 option has been used
  # so there is always a single @@ range and all context lines.

  def initialize(diff_text, options)
    @lines = diff_text.split("\n")
    @n = 0 # index into @lines
    @options = options
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
    n = @n
    one = {
              type: file_type(old_filename, new_filename),
      new_filename: new_filename,
      old_filename: old_filename,
       line_counts: parse_counts
    }
    if @options[:lines]
      @n = n
      one[:lines] = parse_lines
    end
    one
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_lines
    lines = []
    index,old_number,new_number = 0,1,1
    while line && !line.start_with?('diff --git') do
      while same?(line) do
        lines << source_line(:same, line, new_number)
        old_number += 1
        new_number += 1
      end
      if deleted?(line) || added?(line)
        lines << { :type => :section, index:index }
        index += 1
      end
      while deleted?(line) do
        lines << source_line(:deleted, line, old_number)
        old_number += 1
      end
      parse_newline_at_eof
      while added?(line) do
        lines << source_line(:added, line, new_number)
        new_number += 1
      end
      parse_newline_at_eof
    end
    lines
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
    { added:added, deleted:deleted, same:same }
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
        !line.start_with?('@@')           # not in a range
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def parse_range
    if line && line.start_with?('@@')
      next_line
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def source_line(type, line, number)
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

  def same?(line)
    line && line[0] === ' '
  end

  def deleted?(line)
    line && line[0] === '-'
  end

  def added?(line)
    line && line[0] === '+'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def line
    @lines[@n]
  end

  def next_line
    @n += 1
  end

end
