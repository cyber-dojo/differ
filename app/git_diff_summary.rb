# frozen_string_literal: true
require_relative 'git_diff_lib'
require_relative 'git_diff_parser'

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(diff_lines, new_files)
    changed = changed_summary(diff_lines, new_files)
    unchanged = unchanged_summary(new_files, changed)
    changed + unchanged
  end

  private

  def changed_summary(diff_lines, new_files)
    GitDiffParser.new(diff_lines).parse_all.map do |diff|
      type = type_of(diff)
      same = count_lines_same(diff, type, new_files)
      added = count_lines(:added, diff)
      deleted = count_lines(:deleted, diff)
      one_file(type, diff[:old_filename], diff[:new_filename], same, added, deleted)
    end
  end

  def unchanged_summary(new_files, changed)
    unchanged_filenames(new_files.keys, new_filenames(changed)).map do |filename|
      same = new_files[filename].lines.count
      one_file(:unchanged, filename, filename, same, 0, 0)
    end
  end

  def unchanged_filenames(new_filenames, changed_filenames)
    new_filenames - changed_filenames
  end

  def new_filenames(summary)
    summary.collect{ |file| file['new_filename'] }
  end

  def one_file(diff_type, old_filename, new_filename, same, added, deleted)
    {
      'type' => diff_type,
      'old_filename' => old_filename,
      'new_filename' => new_filename,
      'line_counts' => {
        'same'    => same,
        'added'   => added,
        'deleted' => deleted
      }
    }
  end

  def count_lines_same(diff, diff_type, new_files)
    # $ git diff --unified=9999999 ... prints no content for a 100% identical rename.
    if diff_type === :renamed && empty?(diff)
      new_files[diff[:new_filename]].lines.count
    else
      count_lines(:same, diff)
    end
  end

  def count_lines(line_type, diff)
    diff[:lines].count{ |line| line[:type] === line_type }
  end

end
