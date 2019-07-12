require_relative 'git_diff_parser'
require_relative 'git_diff_join_builder'
require_relative 'line_splitter'

module GitDiffJoin # mix-in

  module_function

  def git_diff_join(diff_lines, now_files)
    join = {}
    filenames = now_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |filename, diff|
      if new_file?(diff)
        lines = empty_file?(diff) ? [] : diff[:chunks][0][:added_lines]
        join[filename] = all(lines, :added)
      elsif deleted_file?(diff)
        lines = empty_file?(diff) ? [] : diff[:chunks][0][:deleted_lines]
        join[filename] = all(lines, :deleted)
      else
        now_lines = line_split(now_files[filename])
        join[filename] = git_diff_join_builder(diff, now_lines)
      end
      filenames.delete(filename)
    end
    filenames.each do |filename|
      lines = line_split(now_files[filename])
      join[filename] = all(lines, :same)
    end
    join
  end

  private

  def new_file?(diff)
    diff[:was_filename].nil?
  end

  def deleted_file?(diff)
    diff[:now_filename].nil?
  end

  def empty_file?(diff)
    diff[:chunks] === []
  end

  def all(lines, type)
    lines.collect.each_with_index do |line, number|
      { line: line, type: type, number: number + 1 }
    end
  end

  include LineSplitter
  include GitDiffJoinBuilder

end
