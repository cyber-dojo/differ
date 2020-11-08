# frozen_string_literal: true

module GitDiffLib # mix-in

  module_function

  def git_diff_lines(diffs, new_files)
    changed = changed_lines(diffs, new_files)
    unchanged = unchanged_lines(new_files, changed)
    changed + unchanged
  end

  private

  def changed_lines(diffs, new_files)
    diffs.each do |diff|
      if diff[:type] === :renamed && diff[:line_counts] === { same:0, deleted:0, added:0 }
        # $ git diff --unified=9999999 ... prints no content for identical renames.
        filename = diff[:new_filename]
        file = new_files[filename]
        diff[:line_counts][:same] = file.lines.count
        diff[:lines] = same_lines(file)
      end
    end
    diffs
  end

  def unchanged_lines(new_files, changed)
    all_filenames = new_files.keys
    changed_filenames = changed.collect{ |file| file[:new_filename] }
    unchanged_filenames = all_filenames - changed_filenames
    unchanged_filenames.map do |filename|
      file = new_files[filename]
      {         type: :unchanged,
        old_filename: filename,
        new_filename: filename,
         line_counts: { added:0, deleted:0, same:file.lines.count },
               lines: same_lines(file)
      }
    end
  end

  def same_lines(file)
    if file === ''
      []
    else
      all(:same, file.split("\n"))
    end
  end

  def all(type, lines)
    lines.collect.each.with_index(1) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
