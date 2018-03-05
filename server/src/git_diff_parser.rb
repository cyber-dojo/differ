require_relative 'line_splitter'
class GitDiffParser # Parses the output of 'git diff' command.
    line0 = line
    @n += 1

    lines = []
    while (!line.nil?) &&             # still more lines
          (line !~ /^diff --git/) &&  # not in next file
          (line !~ /^[-]/) &&         # not in --- filename
          (line !~ /^[+]/)            # not in +++ filename
      lines << line
      @n += 1
    end
    [line0] + lines