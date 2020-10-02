# frozen_string_literal: true
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

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
        if empty?(diff)
          lines = [{ :type => :added, number:1, line:'' }]
        else
          lines = diff[:lines]
        end
        joined[new_filename] = lines
      elsif unchanged_rename?(old_filename, old_files, new_filename, new_files)
        lines = line_split(new_files[new_filename])
        joined[new_filename] = all(:same, lines)
      else # changed-file
        joined[new_filename] = diff[:lines]
      end
      filenames.delete(new_filename)
    end
    filenames.each do |unchanged_filename|
      lines = line_split(new_files[unchanged_filename])
      joined[unchanged_filename] = all(:same, lines)
    end
    joined
  end

  # - - - - - - - - - - - - - - - - -

  def git_diff_tip_data(diff_lines, old_files, new_files)
    tip_data = {}
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |diff|
      old_filename = diff[:old_filename]
      new_filename = diff[:new_filename]
      if deleted_file?(diff)
        counts = added_deleted_counts(diff[:lines])
        if counts['added'] + counts['deleted'] > 0
          tip_data[old_filename] = counts
        end
      elsif new_file?(diff)
        if empty?(diff)
          lines = [{ :type => :added, number:1, line:'' }]
        else
          lines = diff[:lines]
        end
        tip_data[new_filename] = added_deleted_counts(lines)
      elsif !unchanged_rename?(old_filename, old_files, new_filename, new_files)
        # changed-file
        tip_data[new_filename] = added_deleted_counts(diff[:lines])
      end
    end
    tip_data
  end

  private

  def added_deleted_counts(lines)
    {
      'added'   => lines.count{ |line| line[:type] === :added   },
      'deleted' => lines.count{ |line| line[:type] === :deleted }
    }
  end

  def empty?(diff)
    diff[:lines] === []
  end

  def line_split(src)
    if src === ''
      ['']
    else
      src.split("\n")
    end
  end

  def unchanged_rename?(old_filename, old_files, new_filename, new_files)
    old_files[old_filename] === new_files[new_filename]
  end

  def new_file?(diff)
    diff[:old_filename].nil?
  end

  def deleted_file?(diff)
    diff[:new_filename].nil?
  end

  def all(type, lines)
    lines.collect.each.with_index(1) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
