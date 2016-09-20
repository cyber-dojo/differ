
require_relative './git_diff_parser'
require_relative './git_diff_view_builder'
require_relative './line_splitter'

module GitDiffView # mix-in

  module_function

  # Creates data structure containing diffs for all files.

  def git_diff_view(diff_lines, visible_files)
    view = {}
    filenames = visible_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |filename, diff|
      if new_file?(diff)
        lines = empty_file?(diff) ? [] : diff[:chunks][0][:sections][0][:added_lines]
        view[filename] = all(lines, :added)
      elsif deleted_file?(diff)
        lines = empty_file?(diff) ? [] : diff[:chunks][0][:sections][0][:deleted_lines]
        view[filename] = all(lines, :deleted)
      else
        lines = line_split(visible_files[filename])
        view[filename] = git_diff_view_builder(diff, lines)
      end
      filenames.delete(filename)
    end
    # other files have not changed...
    filenames.each do |filename|
      lines = line_split(visible_files[filename])
      view[filename] = all(lines, :same)
    end
    view
  end

  private

  def new_file?(diff)
    diff[:was_filename].nil?
  end

  def deleted_file?(diff)
    diff[:now_filename].nil?
  end

  def empty_file?(diff)
    diff[:chunks] == []
  end

  def all(lines, type)
    lines.collect.each_with_index do |line, number|
      { line: line, type: type, number: number + 1 }
    end
  end

  include LineSplitter
  include GitDiffViewBuilder

end
