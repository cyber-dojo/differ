require_relative 'git_diff_parser_lib'
  def initialize(diff_text, options = {})
    @options = options
    one = {
              type: file_type(old_filename, new_filename),
    n = @n
    if @options[:counts]
      one[:line_counts] = parse_counts
    end
    if @options[:lines]
      @n = n
      one[:lines] = parse_lines
    end
    one
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

  include GitDiffParserLib
  def file_type(old_filename, new_filename)
    if old_filename.nil?
      :created
    elsif new_filename.nil?
      :deleted
    elsif old_filename != new_filename
      :renamed
      :changed
  def in_header?(line)
    line &&                             # still more lines
    !line.start_with?('diff --git') &&  # not in next file
    !line.start_with?('@@')             # not in a range