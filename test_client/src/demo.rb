
class Demo

  def call(_env)
    was_files = {
      'cyber-dojo.sh': "blah blah",
      'hiker.c': '#include <hiker.h>',
      'deleted.txt': 'tweedle-dee',
      'compacted.eg':
        [ "def finalize(values)",
          "",
          "  values.each do |v|",
          "    v.finalize",
          "  end",
          "",
          "end"
        ].join("\n")
    }
    now_files = {
      'cyber-dojo.sh': "blah blah blah",
      'hiker.c': '#include "hiker.h"',
      'hiker.h': "#ifndef HIKER_INCLUDED\n#endif",
      'compacted.eg':
        [ "def finalize(values)",
          "",
          "  values.each do |v|",
          "    v.prepare",
          "  end",
          "",
          "  values.each do |v|",
          "    v.finalize",
          "  end",
          "",
          "end"
        ].join("\n")
    }

    json = git_diff(was_files, now_files)
    html = '<pre>' + JSON.pretty_unparse(json) + '</pre>'
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

end
