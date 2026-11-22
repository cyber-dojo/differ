require_relative 'differ_test_base'
require_app 'git_diff_parse_filenames'

class GitDiffParseFilenamesTest < DifferTestBase

  test 'wK7N1A', %w(
  | parse_old_new_filenames gives the old and new filename from each header
  | exactly as git diff --no-prefix --find-renames writes it: a name git
  | writes unquoted, a space included; one it writes quoted, with \\" \\\\ and
  | \\t escapes and \\ooo for each byte of a non-ASCII letter; in a sub-dir,
  | including one named a or b; nil as the old filename of a created file and
  | as the new filename of a deleted one; and a renamed file's names from its
  | rename from and rename to lines
  ) do
    expected = {
      ['diff --git hiker.h hiker.h',
       'index 78981922..61780798 100644'] => ['hiker.h', 'hiker.h'],
      ['diff --git sp ace.txt sp ace.txt',
       'index 78981922..422c2b7a 100644'] => ['sp ace.txt', 'sp ace.txt'],
      ['diff --git "back\\\\slash.txt" "back\\\\slash.txt"',
       'index 78981922..422c2b7a 100644'] => ['back\\slash.txt', 'back\\slash.txt'],
      ['diff --git "ta\\tb.txt" "ta\\tb.txt"',
       'index 78981922..422c2b7a 100644'] => ["ta\tb.txt", "ta\tb.txt"],
      ['diff --git a/b/em bed.h a/b/em bed.h',
       'index 78981922..422c2b7a 100644'] => ['a/b/em bed.h', 'a/b/em bed.h'],
      ['diff --git made name.txt made name.txt',
       'new file mode 100644',
       'index 00000000..f2ad6c76'] => [nil, 'made name.txt'],
      ['diff --git 1/2/3/empty.h 1/2/3/empty.h',
       'new file mode 100644',
       'index 00000000..e69de29b'] => [nil, '1/2/3/empty.h'],
      ['diff --git "quo\\"te.txt" "quo\\"te.txt"',
       'deleted file mode 100644',
       'index 78981922..00000000'] => ['quo"te.txt', nil],
      ['diff --git gone name.txt "new quo\\"te.txt"',
       'similarity index 66%',
       'rename from gone name.txt',
       'rename to "new quo\\"te.txt"',
       'index 78981922..422c2b7a 100644'] => ['gone name.txt', 'new quo"te.txt'],
      ['diff --git "na\\303\\257ve.txt" "n\\303\\251e.txt"',
       'similarity index 66%',
       'rename from "na\\303\\257ve.txt"',
       'rename to "n\\303\\251e.txt"',
       'index 78981922..422c2b7a 100644'] => ['naïve.txt', 'née.txt'],
      ['diff --git 1/2/3/old_name.h 4/5/6/new_name.h',
       'similarity index 100%',
       'rename from 1/2/3/old_name.h',
       'rename to 4/5/6/new_name.h'] => ['1/2/3/old_name.h', '4/5/6/new_name.h']
    }
    actual = expected.keys.to_h { |header| [header, parse_old_new_filenames(header)] }
    assert_equal expected, actual
  end

  include GitDiffParseFilenames
end
