
module LineSplitter # mix-in

  module_function

  def line_split(source)
    if source === ''
      ['']
    else
      lines = source.split(/\n/, -1)
      lines.pop if lines.last === ''
      lines
    end
  end

end

# - - - - - - - - - - - - - - - - -
# Note that
# source = "a\nb"
#   line_split(source)        --> [ "a, "b" ]
# and
#   line_split(source + "\n") --> [ "a, "b" ]
#
# Viz, if the last character is a \n it is 'lost'
# This means that it is not guaranteed that
# line_split(source).join("\n") == source
# - - - - - - - - - - - - - - - - -
