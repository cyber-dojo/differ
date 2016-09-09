
require_relative './git_diff_parser'
require_relative './git_diff_builder'

module GitDiff # mix-in

  module_function

  # Creates data structure containing diffs for all files.

  def git_diff(diff_lines, visible_files)
    view = {}
    diffs = GitDiffParser.new(diff_lines).parse_all
    diffs.each do |path, diff|
      md = %r{^(.)/(.*)}.match(path)
      if md
        filename = md[2]
        if deleted_file?(md[1])
          file_content = []
          if diff[:chunks] != [] # [] indicates empty file was deleted
            file_content = diff[:chunks][0][:sections][0][:deleted_lines]
          end
          view[filename] = deleteify(file_content)
        else
          file_content = visible_files[filename]
          view[filename] = GitDiffBuilder.new.build(diff, LineSplitter.line_split(file_content))
        end
        visible_files.delete(filename)
      end
    end
    # other files have not changed...
    visible_files.each do |filename, content|
      view[filename] = sameify(content)
    end
    view
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def deleted_file?(ch)
    # GitDiffParser uses names beginning with
    # a/... to indicate a deleted file
    # b/... to indicate a new/modified file
    # This mirrors the git diff command output
    ch == 'a'
  end

  def sameify(source)
    ify(LineSplitter.line_split(source), :same)
  end

  def deleteify(lines)
    ify(lines, :deleted)
  end

  def ify(lines, type)
    lines.collect.each_with_index do |line, number|
      { line: line, type: type, number: number + 1 }
    end
  end

end
