# frozen_string_literal: true

module GitDiffLib # mix-in

  module_function

  def git_diff_summary(diffs, new_files)
    changed = changed_summary(diffs, new_files)
    unchanged = unchanged_summary(new_files, changed)
    changed + unchanged
  end

  private

  def changed_summary(diffs, new_files)
    diffs.each do |diff|
      if identical_rename?(diff)
        filename = diff[:new_filename]
        file = new_files[filename]
        diff[:line_counts][:same] = file.lines.count
      end
    end
    diffs
  end

  def unchanged_summary(new_files, changed)
    all_filenames = new_files.keys
    changed_filenames = changed.collect{ |file| file[:new_filename] }
    unchanged_filenames = all_filenames - changed_filenames
    unchanged_filenames.map do |filename|
      {         type: :unchanged,
        old_filename: filename,
        new_filename: filename,
         line_counts: {
             same: new_files[filename].lines.count,
          deleted: 0,
            added: 0
        }
      }
    end
  end

  def identical_rename?(diff)
    # $ git diff --unified=9999999 ...
    # prints no content for identical renames.
    diff[:type] === :renamed &&
      diff[:line_counts] === { same:0, deleted:0, added:0 }
  end

end
