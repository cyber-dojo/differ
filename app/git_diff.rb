# frozen_string_literal: true

module GitDiffLib # mix-in

  module_function

  def git_diff(diffs, new_files, options)
    changed = diff_changed(diffs, new_files, options)
    unchanged = diff_unchanged(new_files, changed, options)
    changed + unchanged
  end

  private

  def diff_changed(diffs, new_files, options)
    diffs.each do |diff|
      if diff[:type] === :renamed && diff[:line_counts] === { same:0, deleted:0, added:0 }
        # $ git diff --unified=9999999 ... prints no content for identical renames.
        filename = diff[:new_filename]
        file = new_files[filename]
        diff[:line_counts][:same] = file.lines.count
        if options[:lines]
          diff[:lines] = same_lines(file)
        end
      end
    end
    diffs
  end

  def diff_unchanged(new_files, changed, options)
    all_filenames = new_files.keys
    changed_filenames = changed.collect{ |file| file[:new_filename] }
    unchanged_filenames = all_filenames - changed_filenames
    unchanged_filenames.map do |filename|
      file = new_files[filename]
      diff = {
                type: :unchanged,
        old_filename: filename,
        new_filename: filename,
         line_counts: { added:0, deleted:0, same:file.lines.count }
      }
      if options[:lines]
        diff[:lines] = same_lines(file)
      end
      diff
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
