require_relative 'git_diff_parser'
require_relative 'git_diff_join_builder'
require_relative 'line_splitter'

module GitDiffJoin # mix-in

  module_function

  def git_diff_join(diff_lines, old_files, new_files)
    join = {}
    filenames = new_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |diff|
      old_filename = diff[:old_filename]
      new_filename = diff[:new_filename]
      if new_file?(diff)
        new_lines = empty_file?(diff) ? [] : diff[:chunks][0][:added]
        join[new_filename] = all(new_lines, :added)
      elsif deleted_file?(diff)
        old_lines = empty_file?(diff) ? [] : diff[:chunks][0][:deleted]
        join[old_filename] = all(old_lines, :deleted)
      else
        old_file = old_files[old_filename]
        old_lines = line_split(old_file)
        new_file = new_files[new_filename]
        new_lines = line_split(new_file)
        join[new_filename] = git_diff_join_builder(diff, old_lines, new_lines)
      end
      filenames.delete(new_filename)
    end
    filenames.each do |filename|
      lines = line_split(new_files[filename])
      join[filename] = all(lines, :same)
    end
    join
  end

  private

  def new_file?(diff)
    diff[:old_filename].nil?
  end

  def deleted_file?(diff)
    diff[:new_filename].nil?
  end

  def empty_file?(diff)
    diff[:chunks] === []
  end

  def all(lines, type)
    lines.collect.each_with_index do |line, index|
      { line:line, type:type, number:index+1 }
    end
  end

  include LineSplitter
  include GitDiffJoinBuilder

end
