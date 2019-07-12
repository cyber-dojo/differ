require_relative 'differ_test_base'
require 'json'
require 'tempfile'

class GitDiffParserTest < DifferTestBase

  def self.hex_prefix
    'B56'
  end

  test '42B',
  'lines are split' do
    lines = [ 'a', 'b' ]
    my_assert_equal lines, GitDiffParser.new(lines.join("\n")).lines
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_was_now_filenames()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D5F',
  'parse old & new filenames with space in both filenames' do
    prefix = [
       'diff --git "a/e mpty.h" "b/e mpty.h"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'e mpty.h', old_filename, :old_filename
    my_assert_equal 'e mpty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1B5',
  'parse old & new filenames with double-quote and space in both filenames' do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/li n\"ux" "b/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "li n\"ux",    old_filename, :old_filename
    my_assert_equal "em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '50A',
  'parse old & new filenames with double-quote and space only in now filename' do
    # git diff only double quotes filenames if it has to
    prefix = [
       'diff --git a/plain "b/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'plain',       old_filename, :was_filename
    my_assert_equal "em bed\"ded", new_filename, :now_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D8',
  'parse old & new filenames with double-quote and space only in was filename' do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/emb ed\"ded" b/plain',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "emb ed\"ded", old_filename, :was_filename
    my_assert_equal 'plain',       new_filename, :now_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '740',
  'new_filename is nil for for deleted file' do
    prefix = [
      'diff --git a/Deleted.java b/Deleted.java',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'Deleted.java', old_filename, :old_filename
    assert_nil new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A9',
  'old_filename is nil for new file' do
    prefix = [
       'diff --git a/empty.h b/empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    assert_nil old_filename, :old_filename
    my_assert_equal 'empty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A90',
  'parse old & new filenames for renamed file' do
    diff_lines = [
      'diff --git a/old_name.h "b/new \"name.h"',
      'similarity index 100%',
      'rename from old_name.h',
      'rename to new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal 'old_name.h',   old_filename, :old_filename
    my_assert_equal "new \"name.h", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD7',
  'parse old & new filenames for new file in nested sub-dir' do
    prefix = [
       'diff --git a/1/2/3/empty.h b/1/2/3/empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    assert_nil old_filename, :old_filename
    my_assert_equal '1/2/3/empty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD8',
  'parse old & new filenames for renamed file in nested sub-dir' do
    diff_lines = [
      'diff --git a/1/2/3/old_name.h b/1/2/3/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 1/2/3/new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    my_assert_equal '1/2/3/new_name.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD9',
  'parse old & new filenames for renamed file across nested sub-dir' do
    diff_lines = [
      'diff --git a/1/2/3/old_name.h b/4/5/6/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 4/5/6/new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    my_assert_equal '4/5/6/new_name.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD0', %w(
    parse old & new nested sub-dir filenames
    with double-quote and space in both filenames
  ) do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/s/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "s/d/f/li n\"ux",    old_filename, :old_filename
    my_assert_equal "u/i/o/em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD1', %w(
    parse old & new nested sub-dir filenames
    with double-quote and space in both filenames
    and where first sub-dir is 'a' or 'b' which could clash
    with git-diff output which uses a/ and b/
  ) do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/a/d/f/li n\"ux" "b/b/u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "a/d/f/li n\"ux",      old_filename, :old_filename
    my_assert_equal "b/u/i/o/em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_all
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E10',
  'parse diff containing filename with backslash' do
    lines = [
      'diff --git "a/\\\\was_newfile_FIU" "b/\\\\was_newfile_FIU"',
      'deleted file mode 100644',
      'index 21984c7..0000000',
      '--- "a/\\\\was_newfile_FIU"',
      '+++ /dev/null',
      '@@ -1 +0,0 @@',
      '-Please rename me!',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    {
      '\\was_newfile_FIU' => # <-- single backslash
      {
        old_filename: '\\was_newfile_FIU', # <-- single backslash
        new_filename: nil,
        chunks:
        [
          {
            old: { start_line:1, size:1 },
            new: { start_line:0, size:0 },
            deleted_lines: [ 'Please rename me!' ],
            added_lines: []
          }
        ]
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '196',
  'parse diff deleted file' do
    lines = [
      'diff --git a/original b/original',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ].join("\n")

    expected =
    {
      'original' =>
      {
        old_filename: 'original',
        new_filename: nil,
        chunks: []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0FE',
  'parse another diff-form of a deleted file' do
    lines = [
      'diff --git a/untitled.rb b/untitled.rb',
      'deleted file mode 100644',
      'index 5c4b3ab..0000000',
      '--- a/untitled.rb',
      '+++ /dev/null',
      '@@ -1,3 +0,0 @@',
      '-def answer',
      '-  42',
      '-end'
    ].join("\n")

    expected =
    {
      'untitled.rb' =>
      {
        old_filename: 'untitled.rb',
        new_filename: nil,
        chunks:
        [
          {
            old: { start_line:1, size:3 },
            new: { start_line:0, size:0 },
            deleted_lines: [ 'def answer', '  42', 'end'],
            added_lines: []
          }
        ]
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D91',
  'parse diff for renamed but unchanged file and newname is quoted' do
    lines = [
      'diff --git "a/was_\\\\wa s_newfile_FIU" "b/\\\\was_newfile_FIU"',
      'similarity index 100%',
      'rename from "was_\\\\wa s_newfile_FIU"',
      'rename to "\\\\was_newfile_FIU"'
    ].join("\n")

    expected =
    {
      '\\was_newfile_FIU' => # <-- single backslash
      {
        old_filename: 'was_\\wa s_newfile_FIU', # <-- single backslash
        new_filename: '\\was_newfile_FIU',      # <-- single backslash
        chunks: []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E38',
  'parse diff for renamed but unchanged file' do
    lines = [
      'diff --git a/oldname b/newname',
      'similarity index 100%',
      'rename from oldname',
      'rename to newname'
    ].join("\n")

    expected =
    {
      'newname' =>
      {
        old_filename: 'oldname',
        new_filename: 'newname',
        chunks: []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A61',
  "parse diff for renamed and changed file" do
    lines = [
      'diff --git a/instructions b/instructions_new',
      'similarity index 87%',
      'rename from instructions',
      'rename to instructions_new',
      'index e747436..83ec100 100644',
      '--- a/instructions',
      '+++ b/instructions_new',
      '@@ -6,1 +6,1 @@ For example, the potential anagrams of "biro" are',
      '-obir obri oibr oirb orbi orib',
      '+obir obri oibr oirb orbi oribx'
    ].join("\n")

    expected_diff =
    {
      old_filename: 'instructions',
      new_filename: 'instructions_new',
      chunks:
      [
        {
          old: { start_line:6, size:1 },
          new: { start_line:6, size:1 },
          deleted_lines: [ 'obir obri oibr oirb orbi orib' ],
          added_lines: [ 'obir obri oibr oirb orbi oribx' ]
        }
      ]
    }

    expected = { 'instructions_new' => expected_diff }
    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    my_assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '91D',
  'parse diffs for two files' do
    lines = [
      'diff --git a/lines b/lines',
      'index 896ddd8..2c8d1b8 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -1,1 +1,1 @@',
      '-ddd',
      '+eee',
      'diff --git a/other b/other',
      'index cf0389a..b28bf03 100644',
      '--- a/other',
      '+++ b/other',
      '@@ -14,2 +14,2 @@',
      '-CCC',
      '-DDD',
      '+EEE',
      '+FFF',
      "\\ No newline at end of file"
    ].join("\n")

    expected_diff_1 =
    {
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
      [
        {
          old: { start_line:1, size:1 },
          new: { start_line:1, size:1 },
          deleted_lines: [ 'ddd' ],
          added_lines: [ 'eee' ]
        }
      ]
    }

    expected_diff_2 =
    {
      old_filename: 'other',
      new_filename: 'other',
      chunks:
      [
        {
          old: { start_line:14, size:2 },
          new: { start_line:14, size:2 },
          deleted_lines: [ 'CCC', 'DDD' ],
          added_lines: [ 'EEE', 'FFF' ]
        }
      ]
    }

    expected =
    {
      'lines' => expected_diff_1,
      'other' => expected_diff_2
    }

    parser = GitDiffParser.new(lines)
    my_assert_equal expected, parser.parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_range
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D56',
  'parse range old-size and new-size defaulted' do
    lines = '@@ -3 +5 @@'
    expected =
    {
      old: { start_line:3, size:1 },
      new: { start_line:5, size:1 },
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AAA',
  'parse range old-size defaulted' do
    lines = '@@ -3 +5,9 @@'
    expected =
    {
      old: { start_line:3, size:1 },
      new: { start_line:5, size:9 },
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '787',
  'parse range new-size defaulted' do
    lines = '@@ -3,4 +5 @@'
    expected =
    {
      old: { start_line:3, size:4 },
      new: { start_line:5, size:1 },
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '64D',
  'parse range nothing defaulted' do
    lines = '@@ -3,4 +5,6 @@'
    expected =
    {
      old: { start_line:3, size:4 },
      new: { start_line:5, size:6 },
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A14',
  'parse no-newline-at-eof without leading backslash' do
    lines = ' No newline at eof'
    parser = GitDiffParser.new(lines)
    assert_equal 0, parser.n
    parser.parse_newline_at_eof
    my_assert_equal 0, parser.n
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9',
  'parse no-newline-at-eof with leading backslash' do
    lines = '\\ No newline at end of file'
    parser = GitDiffParser.new(lines)
    assert_equal 0, parser.n
    parser.parse_newline_at_eof
    my_assert_equal 1, parser.n
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1BC',
  'two chunks with no newline at end of file' do
    lines = [
      'diff --git a/lines b/lines',
      'index b1a30d9..7fa9727 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -3,1 +3,1 @@',
      '-BBB',
      '+CCC',
      '@@ -8,1 +8,1 @@',
      '-SSS',
      '+TTT',
      "\\ No newline at end of file"
    ].join("\n")

    expected =
    {
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
      [
        {
          old: { start_line:3, size:1 },
          new: { start_line:3, size:1 },
          deleted_lines: [ 'BBB' ],
          added_lines: [ 'CCC' ]
        },
        {
          old: { start_line:8, size:1 },
          new: { start_line:8, size:1 },
          deleted_lines: [ 'SSS' ],
          added_lines: [ 'TTT' ]
        }
      ]
    }

    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B2C',
  'diff one-chunk one-line' do
    lines = [
      '@@ -4,1 +4,1 @@',
      '-AAA',
      '+BBB'
    ].join("\n")

    expected =
    {
      old: { start_line:4, size:1 },
      new: { start_line:4, size:1 },
      deleted_lines: [ 'AAA' ],
      added_lines: [ 'BBB' ]
    }

    my_assert_equal expected, GitDiffParser.new(lines).parse_chunk_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E9F',
  'diff one-chunk two-lines' do
    lines = [
      '@@ -17,2 +17,2 @@',
      '-CCC',
      '-DDD',
      '+EEE',
      '+FFF'
    ].join("\n")

    expected =
      [
        {
          old: { start_line:17, size:2 },
          new: { start_line:17, size:2 },
          deleted_lines: [ 'CCC','DDD' ],
          added_lines: [ 'EEE','FFF' ]
        }
      ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_chunk_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A8A',
  'standard diff' do
    lines = [
      'diff --git a/gapper.rb b/gapper.rb',
      'index 26bc41b..8a5b0b7 100644',
      '--- a/gapper.rb',
      '+++ b/gapper.rb',
      '@@ -4,1 +4,2 @@ COMMENT',
      '-XXX',
      '+YYY',
      '+ZZZ'
    ].join("\n")

    expected =
    {
      old_filename: 'gapper.rb',
      new_filename: 'gapper.rb',
      chunks:
      [
        {
          old: { start_line:4, size:1 },
          new: { start_line:4, size:2 },
          deleted_lines: [ 'XXX' ],
          added_lines: [ 'YYY', 'ZZZ' ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3B5',
  'find copies harder finds a rename' do
    lines = [
      'diff --git a/hiker.h b/diamond.h',
      'similarity index 99%',
      'rename from hiker.h',
      'rename to diamond.h',
      'index afcb4df..c0f407c 100644'
    ]
    trailing = [
      '--- a/hiker.h',
      '+++ b/diamond.h'
    ]
    all_lines = (lines + trailing).join("\n")
    my_assert_equal lines, GitDiffParser.new(all_lines).parse_prefix_lines
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C10',
  'diff two chunks' do
    lines = [
      'diff --git a/test_gapper.rb b/test_gapper.rb',
      'index 4d3ca1b..61e88f0 100644',
      '--- a/test_gapper.rb',
      '+++ b/test_gapper.rb',
      '@@ -9,1 +9,1 @@ class TestGapper < Test::Unit::TestCase',
      '-p Timw.now',
      '+p Time.now',
      "\\ No newline at end of file",
      '@@ -19,1 +19,1 @@ class TestGapper < Test::Unit::TestCase',
      '-q Timw.now',
      '+q Time.now'
    ].join("\n")

    expected =
    {
      old_filename: 'test_gapper.rb',
      new_filename: 'test_gapper.rb',
      chunks:
      [
        {
          old: { start_line:9, size:1 },
          new: { start_line:9, size:1 },
          deleted_lines: [ 'p Timw.now' ],
          added_lines: [ 'p Time.now' ]
        },
        {
          old: { start_line:19, size:1 },
          new: { start_line:19, size:1 },
          deleted_lines: [ 'q Timw.now' ],
          added_lines: [ 'q Time.now' ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD3',
  'when diffs are one line apart' do
    lines = [
      'diff --git a/lines b/lines',
      'index 5ed4618..c47ec44 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,1 +5,1 @@ CCC',
      '-DDD',
      '+EEE',
      '@@ -9,1 +9,1 @@ FFF',
      '-GGG',
      '+HHH'
    ].join("\n")

    expected =
    {
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
      [
        {
          old: { start_line:5, size:1 },
          new: { start_line:5, size:1 },
          deleted_lines: [ 'DDD' ],
          added_lines: [ 'EEE' ]
        },
        {
          old: { start_line:9, size:1 },
          new: { start_line:9, size:1 },
          deleted_lines: [ 'GGG' ],
          added_lines: [ 'HHH' ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D3C',
  'when diffs are 2 lines apart' do
    lines = [
      'diff --git a/lines b/lines',
      'index 5ed4618..aad3f67 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,1 +5,1 @@',
      '-DDD',
      '+EEE',
      '@@ -7,1 +7,1 @@',
      '-HHH',
      '+JJJ'
    ].join("\n")

    expected =
    {
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
      [
        {
          old: { start_line:5, size:1 },
          new: { start_line:5, size:1 },
          deleted_lines: [ 'DDD' ],
          added_lines: [ 'EEE' ]
        },
        {
          old: { start_line:7, size:1 },
          new: { start_line:7, size:1 },
          deleted_lines: [ 'HHH' ],
          added_lines: [ 'JJJ' ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '274',
  '7 unchanged lines between two changed lines',
  'creates two chunks' do
    lines = [
      'diff --git a/lines b/lines',
      'index 5ed4618..e78c888 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,1 +5,1 @@',
      '-DDD',
      '+EEE',
      '@@ -13,1 +13,1 @@',
      '-TTT',
      '+UUU'
    ].join("\n")

    expected =
    {
       old_filename: 'lines',
       new_filename: 'lines',
       chunks:
       [
         {
           old: { start_line:5, size:1 },
           new: { start_line:5, size:1 },
           deleted_lines: [ 'DDD' ],
           added_lines: [ 'EEE' ]
         },
         {
           old: { start_line:13, size:1 },
           new: { start_line:13, size:1 },
           deleted_lines: [ 'TTT' ],
           added_lines: [ 'UUU' ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '8E3',
  'no-newline-at-end-of-file line at end of',
  'common section is gobbled' do
    # James Grenning built his own cyber-dojo server
    # which he uses for training. He noticed that a file
    # called CircularBufferTests.cpp
    # changed between two traffic-lights but the diff-view
    # was not displaying the diff. He sent me a zip of the
    # avatars git repository and I confirmed that
    #   git diff 8 9 sandbox/CircularBufferTests.cpp
    # produced the following output
    lines = [
      'diff --git a/sandbox/CircularBufferTest.cpp b/sandbox/CircularBufferTest.cpp',
      'index 0ddb952..a397f48 100644',
      '--- a/sandbox/CircularBufferTest.cpp',
      '+++ b/sandbox/CircularBufferTest.cpp',
      '@@ -35,3 +35,8 @@ TEST(CircularBuffer, EmptyAfterCreation)',
      '\\ No newline at end of file',
      '+',
      '+TEST(CircularBuffer, NotFullAfterCreation)',
      '+{',
      '+    CHECK_FALSE(CircularBuffer_IsFull(buffer));',
      '+}',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    {
      old_filename: 'sandbox/CircularBufferTest.cpp',
      new_filename: 'sandbox/CircularBufferTest.cpp',
      chunks:
      [
        {
          old: { start_line:35, size:3 },
          new: { start_line:35, size:8 },
          deleted_lines: [],
          added_lines:
          [
            '',
            'TEST(CircularBuffer, NotFullAfterCreation)',
            '{',
            '    CHECK_FALSE(CircularBuffer_IsFull(buffer));',
            '}'
          ]
        }
      ]
    }
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '124',%w(
    renamed but unchanged file has no trailing
    --- or +++ lines and must not consume diff
    of following file as its prefix_lines
  ) do

    diff_lines = [
      'diff --git a/hiker.h b/hiker.txt',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to hiker.txt',
      'diff --git a/wibble.c b/wibble.c',
      'index eff4ff4..2ca787d 100644',
      '--- a/wibble.c',
      '+++ b/wibble.c',
      '@@ -1,2 +1,3 @@',
      '+abc',
      '\\ No newline at end of file'
    ].join("\n")

    expected_diff_1 =
    {
      old_filename: "hiker.h",
      new_filename: "hiker.txt",
      chunks: []
    }
    expected_diff_2 =
    {
       old_filename: 'wibble.c',
       new_filename: 'wibble.c',
       chunks:
       [
         {
           old: { start_line:1, size:2 },
           new: { start_line:1, size:3 },
           deleted_lines: [],
           added_lines: ['abc']
         }
       ]
    }

    expected_diffs =
    {
      'hiker.txt' => expected_diff_1,
      'wibble.c'  => expected_diff_2
    }

    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs
  end

end
