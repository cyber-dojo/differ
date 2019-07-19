require_relative 'git_diff_parser'

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
        joined[old_filename] = diff[:lines]
      elsif new_file?(diff)
        joined[new_filename] = diff[:lines]
      elsif unchanged_rename?(old_filename, old_files, new_filename, new_files)
        lines = new_files[new_filename].split("\n")
        joined[new_filename] = all(lines, :same)
      else # changed-file
        joined[new_filename] = diff[:lines]
      end
      filenames.delete(new_filename)
    end
    filenames.each do |unchanged_filename|
      lines = new_files[unchanged_filename].split("\n")
      joined[unchanged_filename] = all(lines, :same)
    end
    joined
  end

  private

  def unchanged_rename?(old_filename, old_files, new_filename, new_files)
    old_files[old_filename] === new_files[new_filename]
  end

  def new_file?(diff)
    diff[:old_filename].nil?
  end

  def deleted_file?(diff)
    diff[:new_filename].nil?
  end

  def all(lines, type)
    lines.collect.each.with_index(1) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
