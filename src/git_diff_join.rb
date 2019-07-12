require_relative 'git_diff_parser'
require_relative 'git_diff_join_builder'
require_relative 'line_splitter'

module GitDiffJoin # mix-in

  module_function

  def git_diff_join(diff_lines, old_files, now_files)
    join = {}
    filenames = now_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |_filename, diff|
      if new_file?(diff)
        new_filename = diff[:new_filename]
        new_lines = empty_file?(diff) ? [] : diff[:chunks][0][:added_lines]
        join[new_filename] = all(new_lines, :added)
      elsif deleted_file?(diff)
        old_filename = diff[:old_filename]
        old_lines = empty_file?(diff) ? [] : diff[:chunks][0][:deleted_lines]
        join[old_filename] = all(old_lines, :deleted)
      else
        was_file = was_files[diff[:was_filename]]
        was_lines = line_split(was_file)
        #now_lines = line_split(now_files[filename])
        join[filename] = git_diff_join_builder(diff, was_lines)
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
