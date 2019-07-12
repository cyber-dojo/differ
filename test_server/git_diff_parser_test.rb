require 'json'
require 'tempfile'
    my_assert_equal lines, GitDiffParser.new(lines.join("\n")).lines
  # parse_old_new_filenames()
  'parse old & new filenames with space in both filenames' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'e mpty.h', old_filename, :old_filename
    my_assert_equal 'e mpty.h', new_filename, :new_filename
  'parse old & new filenames with double-quote and space in both filenames' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "li n\"ux",    old_filename, :old_filename
    my_assert_equal "em bed\"ded", new_filename, :new_filename
  'parse old & new filenames with double-quote and space only in new-filename' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'plain',       old_filename, :old_filename
    my_assert_equal "em bed\"ded", new_filename, :new_filename
  'parse old & new filenames with double-quote and space only in old-filename' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "emb ed\"ded", old_filename, :old_filename
    my_assert_equal 'plain',       new_filename, :new_filename
  'new_filename is nil for for deleted file' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal 'Deleted.java', old_filename, :old_filename
    assert_nil new_filename, :new_filename
  'old_filename is nil for new file' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    assert_nil old_filename, :old_filename
    my_assert_equal 'empty.h', new_filename, :new_filename
  'parse old & new filenames for renamed file' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal 'old_name.h',   old_filename, :old_filename
    my_assert_equal "new \"name.h", new_filename, :new_filename
  'parse old & new filenames for new file in nested sub-dir' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    assert_nil old_filename, :old_filename
    my_assert_equal '1/2/3/empty.h', new_filename, :new_filename
  'parse old & new filenames for renamed file in nested sub-dir' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    my_assert_equal '1/2/3/new_name.h', new_filename, :new_filename
  'parse old & new filenames for renamed file across nested sub-dir' do
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(diff_lines)
    my_assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    my_assert_equal '4/5/6/new_name.h', new_filename, :new_filename
    parse old & new nested sub-dir filenames
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "s/d/f/li n\"ux",    old_filename, :old_filename
    my_assert_equal "u/i/o/em bed\"ded", new_filename, :new_filename
    parse old & new nested sub-dir filenames
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(prefix)
    my_assert_equal "a/d/f/li n\"ux",      old_filename, :old_filename
    my_assert_equal "b/u/i/o/em bed\"ded", new_filename, :new_filename
    [
        old_filename: '\\was_newfile_FIU', # <-- single backslash
        new_filename: nil,
        chunks:
            old_start_line:1,
            deleted: [ 'Please rename me!' ],
            new_start_line:0,
            added: []
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
    [
        old_filename: 'original',
        new_filename: nil,
        chunks: []
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
    [
        old_filename: 'untitled.rb',
        new_filename: nil,
        chunks:
            old_start_line:1,
            deleted: [ 'def answer', '  42', 'end'],
            new_start_line:0,
            added: []
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
    [
        old_filename: 'was_\\wa s_newfile_FIU', # <-- single backslash
        new_filename: '\\was_newfile_FIU',      # <-- single backslash
        chunks: []
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
    [
        old_filename: 'oldname',
        new_filename: 'newname',
        chunks: []
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
      '@@ -6,1 +6,1 @@ For example, the potential anagrams of "biro" are',
    expected =
    [
      {
        old_filename: 'instructions',
        new_filename: 'instructions_new',
        chunks:
        [
          {
            old_start_line:6,
            deleted: [ 'obir obri oibr oirb orbi orib' ],
            new_start_line:6,
            added: [ 'obir obri oibr oirb orbi oribx' ]
          }
        ]
      }
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
      '@@ -1,1 +1,1 @@',
      '@@ -14,2 +14,2 @@',
    [
      {
        old_filename: 'lines',
        new_filename: 'lines',
        chunks:
        [
          {
            old_start_line:1,
            deleted: [ 'ddd' ],
            new_start_line:1,
            added: [ 'eee' ]
          }
        ]
      },
      {
        old_filename: 'other',
        new_filename: 'other',
        chunks:
        [
          {
            old_start_line:14,
            deleted: [ 'CCC', 'DDD' ],
            new_start_line:14,
            added: [ 'EEE', 'FFF' ]
          }
        ]
      }
    ]
    my_assert_equal expected, GitDiffParser.new(lines).parse_all
  'parse range old-size and new-size defaulted' do
    expected = { old_start_line:3, new_start_line:5 }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  'parse range old-size defaulted' do
    expected = { old_start_line:3, new_start_line:5 }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
  'parse range new-size defaulted' do
    expected = { old_start_line:3, new_start_line:5 }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
    expected = { old_start_line:3, new_start_line:5 }
    my_assert_equal expected, GitDiffParser.new(lines).parse_range
    my_assert_equal 0, parser.n
    my_assert_equal 1, parser.n
      '@@ -3,1 +3,1 @@',
      '@@ -8,1 +8,1 @@',
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
      [
        {
          old_start_line:3,
          deleted: [ 'BBB' ],
          new_start_line:3,
          added: [ 'CCC' ]
        },
        {
          old_start_line:8,
          deleted: [ 'SSS' ],
          new_start_line:8,
          added: [ 'TTT' ]
        }
      ]
    }

    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  'diff one-chunk one-line' do
      '@@ -4,1 +4,1 @@',
      '+BBB'
      old_start_line:4,
      deleted: [ 'AAA' ],
      new_start_line:4,
      added: [ 'BBB' ]
    }

    my_assert_equal expected, GitDiffParser.new(lines).parse_chunk
  'diff one-chunk two-lines' do
      '@@ -17,2 +17,2 @@',
      '-DDD',
      '+EEE',
      '+FFF'
    [
      {
        old_start_line:17,
        deleted: [ 'CCC','DDD' ],
        new_start_line:17,
        added: [ 'EEE','FFF' ]
      }
    ]

    my_assert_equal expected, GitDiffParser.new(lines).parse_chunks
      '@@ -4,1 +4,2 @@ COMMENT',
      '+ZZZ'
      old_filename: 'gapper.rb',
      new_filename: 'gapper.rb',
      chunks:
          old_start_line:4,
          deleted: [ 'XXX' ],
          new_start_line:4,
          added: [ 'YYY', 'ZZZ' ]

    my_assert_equal expected, GitDiffParser.new(lines).parse_one

    my_assert_equal lines, GitDiffParser.new(all_lines).parse_prefix_lines
      '@@ -9,1 +9,1 @@ class TestGapper < Test::Unit::TestCase',
      '@@ -19,1 +19,1 @@ class TestGapper < Test::Unit::TestCase',
      old_filename: 'test_gapper.rb',
      new_filename: 'test_gapper.rb',
      chunks:
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

    my_assert_equal expected, GitDiffParser.new(lines).parse_one
      '@@ -5,1 +5,1 @@ CCC',
      '@@ -9,1 +9,1 @@ FFF',
      '+HHH'
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
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

    my_assert_equal expected, GitDiffParser.new(lines).parse_one
      '@@ -5,1 +5,1 @@',
      '@@ -7,1 +7,1 @@',
      '+JJJ'
      old_filename: 'lines',
      new_filename: 'lines',
      chunks:
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
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
      '@@ -5,1 +5,1 @@',
      '@@ -13,1 +13,1 @@',
      '+UUU'
       old_filename: 'lines',
       new_filename: 'lines',
       chunks:
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
    my_assert_equal expected, GitDiffParser.new(lines).parse_one
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
      '+abc',
    expected =
    [
      {
        old_filename: "hiker.h",
        new_filename: "hiker.txt",
        chunks: []
      },
      {
         old_filename: 'wibble.c',
         new_filename: 'wibble.c',
         chunks:
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
    my_assert_equal expected, GitDiffParser.new(diff_lines).parse_all