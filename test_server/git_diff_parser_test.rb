require_relative 'differ_test_base'
require 'json'
require 'tempfile'

class GitDiffParserTest < DifferTestBase

  def self.hex_prefix
    'B56'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_old_new_filenames()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D5F',
  'parse old & new filenames with space in both filenames' do
    header = [
       'diff --git "e mpty.h" "e mpty.h"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal 'e mpty.h', old_filename, :old_filename
    assert_equal 'e mpty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1B5',
  'parse old & new filenames with double-quote and space in both filenames' do
    # double-quote " is a legal character in a linux filename
    header = [
       'diff --git "li n\"ux" "em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal "li n\"ux",    old_filename, :old_filename
    assert_equal "em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '50A',
  'parse old & new filenames with double-quote and space only in new-filename' do
    # git diff only double quotes filenames if it has to
    header = [
       'diff --git plain "em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal 'plain',       old_filename, :old_filename
    assert_equal "em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D8',
  'parse old & new filenames with double-quote and space only in old-filename' do
    # double-quote " is a legal character in a linux filename
    header = [
       'diff --git "emb ed\"ded" plain',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal "emb ed\"ded", old_filename, :old_filename
    assert_equal 'plain',       new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '740',
  'new_filename is nil for for deleted file' do
    header = [
      'diff --git Deleted.java Deleted.java',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal 'Deleted.java', old_filename, :old_filename
    assert_nil new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A9',
  'old_filename is nil for new file' do
    header = [
       'diff --git empty.h empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_nil old_filename, :old_filename
    assert_equal 'empty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A90',
  'parse old & new filenames for renamed file' do
    diff_lines = [
      'diff --git old_name.h "new \"name.h"',
      'similarity index 100%',
      'rename from old_name.h',
      'rename to new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    assert_equal 'old_name.h',   old_filename, :old_filename
    assert_equal "new \"name.h", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD7',
  'parse old & new filenames for new file in nested sub-dir' do
    header = [
       'diff --git 1/2/3/empty.h 1/2/3/empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_nil old_filename, :old_filename
    assert_equal '1/2/3/empty.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD8',
  'parse old & new filenames for renamed file in nested sub-dir' do
    diff_lines = [
      'diff --git 1/2/3/old_name.h 1/2/3/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 1/2/3/new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '1/2/3/new_name.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD9',
  'parse old & new filenames for renamed file across nested sub-dir' do
    diff_lines = [
      'diff --git 1/2/3/old_name.h 4/5/6/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 4/5/6/new_name.h'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '4/5/6/new_name.h', new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD0', %w(
    parse old & new nested sub-dir filenames
    with double-quote and space in both filenames
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
       'diff --git "s/d/f/li n\"ux" "u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal "s/d/f/li n\"ux",    old_filename, :old_filename
    assert_equal "u/i/o/em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD1', %w(
    parse old & new nested sub-dir filenames
    with double-quote and space in both filenames
    and where first sub-dir is 'a' or 'b' which could clash
    with git-diff output which uses a/ and b/
  ) do
    # double-quote " is a legal character in a linux filename
    header = [
       'diff --git "a/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    assert_equal "a/d/f/li n\"ux",      old_filename, :old_filename
    assert_equal "b/u/i/o/em bed\"ded", new_filename, :new_filename
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_all
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E10',
  'parse diff containing filename with backslash' do
    lines = [
      'diff --git "\\\\was_newfile_FIU" "\\\\was_newfile_FIU"',
      'deleted file mode 100644',
      'index 21984c7..0000000',
      '--- "\\\\was_newfile_FIU"',
      '+++ /dev/null',
      '@@ -1 +0,0 @@',
      '-Please rename me!',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    [
      {
        old_filename: '\\was_newfile_FIU', # <-- single backslash
        new_filename: nil,
        lines:
        [
          section(0),
          deleted(1, 'Please rename me!'),
        ]
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '196',
  'parse diff deleted file' do
    lines = [
      'diff --git original original',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ].join("\n")

    expected =
    [
      {
        old_filename: 'original',
        new_filename: nil,
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0FE',
  'parse another diff-form of a deleted file' do
    lines = [
      'diff --git untitled.rb untitled.rb',
      'deleted file mode 100644',
      'index 5c4b3ab..0000000',
      '--- untitled.rb',
      '+++ /dev/null',
      '@@ -1,3 +0,0 @@',
      '-def answer',
      '-  42',
      '-end'
    ].join("\n")

    expected =
    [
      {
        old_filename: 'untitled.rb',
        new_filename: nil,
        lines:
        [
          section(0),
          deleted(1, 'def answer'),
          deleted(2, '  42'),
          deleted(3, 'end'),
        ]
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D91',
  'parse diff for renamed but unchanged file and newname is quoted' do
    lines = [
      'diff --git "was_\\\\wa s_newfile_FIU" "\\\\was_newfile_FIU"',
      'similarity index 100%',
      'rename from "was_\\\\wa s_newfile_FIU"',
      'rename to "\\\\was_newfile_FIU"'
    ].join("\n")

    expected =
    [
      {
        old_filename: 'was_\\wa s_newfile_FIU', # <-- single backslash
        new_filename: '\\was_newfile_FIU',      # <-- single backslash
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E38',
  'parse diff for renamed but unchanged file' do
    lines = [
      'diff --git oldname newname',
      'similarity index 100%',
      'rename from oldname',
      'rename to newname'
    ].join("\n")

    expected =
    [
      {
        old_filename: 'oldname',
        new_filename: 'newname',
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A61',
  "parse diff for renamed and changed file" do
    lines = [
      'diff --git instructions instructions_new',
      'similarity index 87%',
      'rename from instructions',
      'rename to instructions_new',
      'index dc12fc4..08a6241 100644',
      '--- instructions',
      '+++ instructions_new',
      '@@ -1,10 +1,10 @@',
      ' Write a program to generate all potential',
      ' anagrams of an input string.',
      ' ',
      ' For example, the potential anagrams of "biro" are',
      ' ',
      ' biro bior brio broi boir bori',
      ' ibro ibor irbo irob iobr iorb',
      ' rbio rboi ribo riob roib robi',
      '-obir obri oibr oirb orbi orib',
      '+obir obri oibr oirb orbi oribx',
      ' ',
    ].join("\n")

    expected =
    [
      {
        old_filename: 'instructions',
        new_filename: 'instructions_new',
        lines:
        [
            same(1, 'Write a program to generate all potential'),
            same(2, 'anagrams of an input string.'),
            same(3, ''),
            same(4, 'For example, the potential anagrams of "biro" are'),
            same(5, ''),
            same(6, 'biro bior brio broi boir bori'),
            same(7, 'ibro ibor irbo irob iobr iorb'),
            same(8, 'rbio rboi ribo riob roib robi'),
            section(0),
            deleted(9, 'obir obri oibr oirb orbi orib'),
            added(9, 'obir obri oibr oirb orbi oribx'),
            same(10, ''),
        ]
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '91D',
  'parse diffs for two files' do
    lines = [
      'diff --git lines lines',
      'index 1d60b70..14fc1c2 100644',
      '--- lines',
      '+++ lines',
      '@@ -1 +1 @@',
      '-ddd',
      '+eee',
      'diff --git other other',
      'index f72fee1..9b29445 100644',
      '--- other',
      '+++ other',
      '@@ -1,4 +1,4 @@',
      ' AAA',
      ' BBB',
      '-CCC',
      '-DDD',
      '+EEE',
      '+FFF',
    ].join("\n")

    expected =
    [
      {
        old_filename: 'lines',
        new_filename: 'lines',
        lines:
        [
          section(0),
          deleted(1, 'ddd'),
          added(1, 'eee'),
        ]
      },
      {
        old_filename: 'other',
        new_filename: 'other',
        lines:
        [
          same(1, 'AAA'),
          same(2, 'BBB'),
          section(0),
          deleted(3, 'CCC'),
          deleted(4, 'DDD'),
          added(3, 'EEE'),
          added(4, 'FFF'),
        ]
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1BC',
  'two hunks with no newline at end of file' do
    lines = [
      'diff --git lines lines',
      'index f70c2c0..ba0f878 100644',
      '--- lines',
      '+++ lines',
      '@@ -1,4 +1,5 @@',
      ' aaa',
      '-bbb',
      '+BBB',
      ' ccc',
      ' ddd',
      '+EEE',
      '\ No newline at end of file',
    ].join("\n")

    expected =
    {
      old_filename: 'lines',
      new_filename: 'lines',
      lines:
      [
        same(1, 'aaa'),
        section(0),
        deleted(2, 'bbb'),
        added(2, 'BBB'),
        same(3, 'ccc'),
        same(4, 'ddd'),
        section(1),
        added(5, 'EEE'),
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B2C',
  'diff one-hunk one-line' do
    lines = [
      '@@ -4,1 +4,1 @@',
      '-AAA',
      '+BBB'
    ].join("\n")

    expected =
    {
      old_start_line:4,
      deleted: [ 'AAA' ],
      new_start_line:4,
      added: [ 'BBB' ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_hunk
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E9F',
  'diff one-hunk two-lines' do
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
        old_start_line:17,
        deleted: [ 'CCC','DDD' ],
        new_start_line:17,
        added: [ 'EEE','FFF' ]
      }
    ]

    assert_equal expected, GitDiffParser.new(lines).parse_hunks
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A8A',
  'standard diff' do
    lines = [
      'diff --git gapper.rb gapper.rb',
      'index 26bc41b..8a5b0b7 100644',
      '--- gapper.rb',
      '+++ gapper.rb',
      '@@ -4,1 +4,2 @@ COMMENT',
      '-XXX',
      '+YYY',
      '+ZZZ'
    ].join("\n")

    expected =
    {
      old_filename: 'gapper.rb',
      new_filename: 'gapper.rb',
      hunks:
      [
        {
          old_start_line:4,
          deleted: [ 'XXX' ],
          new_start_line:4,
          added: [ 'YYY', 'ZZZ' ]
        }
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3B5',
  'find copies harder finds a rename' do
    lines = [
      'diff --git hiker.h diamond.h',
      'similarity index 99%',
      'rename from hiker.h',
      'rename to diamond.h',
      'index afcb4df..c0f407c 100644',
      '--- hiker.h',
      '+++ diamond.h'
    ]
    assert_equal lines, GitDiffParser.new(lines.join("\n")).parse_header
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C10',
  'diff two hunks' do
    lines = [
      'diff --git test_gapper.rb test_gapper.rb',
      'index 4d3ca1b..61e88f0 100644',
      '--- test_gapper.rb',
      '+++ test_gapper.rb',
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
      hunks:
      [
        {
          old_start_line:9,
          deleted: [ 'p Timw.now' ],
          new_start_line:9,
          added: [ 'p Time.now' ]
        },
        {
          old_start_line:19,
          deleted: [ 'q Timw.now' ],
          new_start_line:19,
          added: [ 'q Time.now' ]
        }
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD3',
  'when diffs are one line apart' do
    lines = [
      'diff --git lines lines',
      'index 5ed4618..c47ec44 100644',
      '--- lines',
      '+++ lines',
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
      hunks:
      [
        {
          old_start_line:5,
          deleted: [ 'DDD' ],
          new_start_line:5,
          added: [ 'EEE' ]
        },
        {
          old_start_line:9,
          deleted: [ 'GGG' ],
          new_start_line:9,
          added: [ 'HHH' ]
        }
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D3C',
  'when diffs are 2 lines apart' do
    lines = [
      'diff --git lines lines',
      'index 5ed4618..aad3f67 100644',
      '--- lines',
      '+++ lines',
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
      hunks:
      [
        {
          old_start_line:5,
          deleted: [ 'DDD' ],
          new_start_line:5,
          added: [ 'EEE' ]
        },
        {
          old_start_line:7,
          deleted: [ 'HHH' ],
          new_start_line:7,
          added: [ 'JJJ' ]
        }
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '274',
  '7 unchanged lines between two changed lines',
  'creates two hunks' do
    lines = [
      'diff --git lines lines',
      'index 5ed4618..e78c888 100644',
      '--- lines',
      '+++ lines',
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
       hunks:
       [
         {
           old_start_line:5,
           deleted: [ 'DDD' ],
           new_start_line:5,
           added: [ 'EEE' ]
         },
         {
           old_start_line:13,
           deleted: [ 'TTT' ],
           new_start_line:13,
           added: [ 'UUU' ]
        }
      ]
    }

    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '124',%w(
    renamed but unchanged file has no trailing
    --- or +++ lines and must not consume diff
    of following file as its header_lines
  ) do

    diff_lines = [
      'diff --git hiker.h hiker.txt',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to hiker.txt',
      'diff --git wibble.c wibble.c',
      'index eff4ff4..2ca787d 100644',
      '--- wibble.c',
      '+++ wibble.c',
      '@@ -1,2 +1,3 @@',
      '+abc',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    [
      {
        old_filename: "hiker.h",
        new_filename: "hiker.txt",
        hunks: []
      },
      {
         old_filename: 'wibble.c',
         new_filename: 'wibble.c',
         hunks:
         [
           {
             old_start_line:1,
             deleted: [],
             new_start_line:1,
             added: ['abc']
           }
         ]
      }
    ]

    assert_equal expected, GitDiffParser.new(diff_lines).parse_all
  end

  private

  def section(index)
    { :type => :section, index:index }
  end

  def same(number, line)
    src(:same, number, line)
  end

  def deleted(number, line)
    src(:deleted, number, line)
  end

  def added(number, line)
    src(:added, number, line)
  end

  def src(type, number, line)
    { type:type, number:number, line:line }
  end

end
