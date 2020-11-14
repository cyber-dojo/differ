# frozen_string_literal: true

module GitDiffLib # mix-in

  module_function

  def git_diff(changed, new_files, options)
    fill_identical_renamed_files(changed, new_files, options)
    changed + unchanged_files(new_files, changed, options)
  end

  private

  def fill_identical_renamed_files(diffs, new_files, options)
    # Created entries for identical renames.
    # $ git diff ... prints no content in this case.
    diffs.each do |diff|
      if diff[:type] === :renamed && diff[:line_counts] === { same:0, deleted:0, added:0 }
        filename = diff[:new_filename]
        file = new_files[filename]
        diff[:line_counts][:same] = file.lines.count
        if options[:lines]
          diff[:lines] = same_lines(file)
        end
      end
    end
  end

  def unchanged_files(new_files, changed, options)
    # Creates entries for unchanged files.
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
      file.split("\n").collect.with_index(1) do |line,number|
        { type: :same, line:line, number:number }
      end
    end
  end

end
