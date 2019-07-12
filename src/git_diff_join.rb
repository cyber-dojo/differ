require_relative 'git_diff_parser'
require_relative 'git_diff_join_builder'
require_relative 'line_splitter'

module GitDiffJoin # mix-in

  module_function

  def git_diff_join(diff_lines, old_files, new_files)
    joined = {}
    filenames = new_files.keys
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |diff|
      old_filename = diff[:old_filename]
      new_filename = diff[:new_filename]
      if deleted_file?(diff)
        old_lines = empty_file?(diff) ? [] : diff[:chunks][0][:deleted]
        joined[old_filename] = all(old_lines, :deleted)
      elsif new_file?(diff)
        new_lines = empty_file?(diff) ? [] : diff[:chunks][0][:added]
        joined[new_filename] = all(new_lines, :added)
      else # changed-file
        old_lines = line_split(old_files[old_filename])
        joined[new_filename] = git_diff_join_builder(diff, old_lines)
      end
      filenames.delete(new_filename)
    end
    filenames.each do |unchanged_filename|
      lines = line_split(new_files[unchanged_filename])
      joined[unchanged_filename] = all(lines, :same)
    end
    joined
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
    lines.collect.each.with_index(1) do |line,number|
      { line:line, type:type, number:number }
    end
  end

  include LineSplitter
  include GitDiffJoinBuilder

end
