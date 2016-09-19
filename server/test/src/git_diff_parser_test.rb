
require_relative './lib_test_base'

class GitDiffParserTest < LibTestBase

  def self.hex(suffix)
    'B56' + suffix
  end

  test '42B',
  'lines are split' do
    lines = [ 'a', 'b' ]
    assert_equal lines, GitDiffParser.new(lines.join("\n")).lines
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_was_now_filenames()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D5F',
  'parse was & now filenames with space in both filenames' do
    prefix = [
       'diff --git "a/e mpty.h" "b/e mpty.h"',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal 'e mpty.h', was_filename, 'was_filename'
    assert_equal 'e mpty.h', now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1B5',
  'parse was & now filenames with double-quote and space in both filenames' do
    # " is a legal character in a linux filename"
    prefix = [
       'diff --git "a/li n\"ux" "b/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal "li n\"ux", was_filename, 'was_filename'
    assert_equal "em bed\"ded", now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '50A',
  'parse was & now filenames with double-quote and space only in now filename' do
    # git diff only double quotes filenames if it has to
    prefix = [
       'diff --git a/plain "b/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal "plain", was_filename, 'was_filename'
    assert_equal "em bed\"ded", now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4D8',
  'parse was & now filenames with double-quote and space only in was filename' do
    # " is a legal character in a linux filename"
    prefix = [
       'diff --git "a/emb ed\"ded" b/plain',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal "emb ed\"ded", was_filename, 'was_filename'
    assert_equal "plain", now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '740',
  'now_filename is nil for for deleted file' do
    prefix = [
      'diff --git a/Deleted.java b/Deleted.java',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal 'Deleted.java', was_filename, 'was_filename'
    assert_nil now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2A9',
  'was_filename is nil for new file' do
    prefix = [
       'diff --git a/empty.h b/empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_nil was_filename, 'was_filename'
    assert_equal 'empty.h', now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A90',
  'parse was & now filenames for renamed file' do
    diff_lines = [
      'diff --git a/old_name.h "b/new \"name.h"',
      'similarity index 100%',
      'rename from old_name.h',
      'rename to new_name.h'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(diff_lines)
    assert_equal 'old_name.h', was_filename, 'was_filename'
    assert_equal "new \"name.h", now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_all
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E10',
  'parse diff containing filename with backslash' do
    lines = [
      'diff --git "a/sandbox/\\\\was_newfile_FIU" "b/sandbox/\\\\was_newfile_FIU"',
      'deleted file mode 100644',
      'index 21984c7..0000000',
      '--- "a/sandbox/\\\\was_newfile_FIU"',
      '+++ /dev/null',
      '@@ -1 +0,0 @@',
      '-Please rename me!',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    {
      'sandbox/\\was_newfile_FIU' => # <-- single backslash
      {
        :prefix_lines =>
        [
            'diff --git "a/sandbox/\\\\was_newfile_FIU" "b/sandbox/\\\\was_newfile_FIU"',
            'deleted file mode 100644',
            'index 21984c7..0000000',
        ],
        :was_filename => 'sandbox/\\was_newfile_FIU', # <-- single backslash
        :now_filename => nil,
        :chunks       =>
        [
          {
            :range =>
            {
              :now => { :size => 0, :start_line => 0 },
              :was => { :size => 1, :start_line => 1 }
            },
            :sections =>
            [
              {
                :deleted_lines => [ 'Please rename me!' ],
                :added_lines   => [],
                :after_lines   => []
              }
            ],
            :before_lines => []
          }
        ]
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '196',
  'parse diff deleted file' do
    lines = [
      'diff --git a/sandbox/original b/sandbox/original',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ].join("\n")

    expected =
    {
      'sandbox/original' =>
      {
        :prefix_lines =>
        [
            'diff --git a/sandbox/original b/sandbox/original',
            'deleted file mode 100644',
            'index e69de29..0000000',
        ],
        :was_filename => 'sandbox/original',
        :now_filename => nil,
        :chunks       => []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0FE',
  'parse another diff-form of a deleted file' do
    lines = [
      'diff --git a/sandbox/untitled.rb b/sandbox/untitled.rb',
      'deleted file mode 100644',
      'index 5c4b3ab..0000000',
      '--- a/sandbox/untitled.rb',
      '+++ /dev/null',
      '@@ -1,3 +0,0 @@',
      '-def answer',
      '-  42',
      '-end'
    ].join("\n")

    expected =
    {
      'sandbox/untitled.rb' =>
      {
        :prefix_lines =>
        [
            'diff --git a/sandbox/untitled.rb b/sandbox/untitled.rb',
            'deleted file mode 100644',
            'index 5c4b3ab..0000000',
        ],
        :was_filename => 'sandbox/untitled.rb',
        :now_filename => nil,
        :chunks =>
        [
          {
            :range =>
            {
              :was => { :start_line => 1, :size       => 3 },
              :now => { :start_line => 0, :size       => 0 }
            },
            :before_lines => [],
            :sections     =>
            [
              {
              :deleted_lines => [ 'def answer', '  42', 'end'],
              :added_lines   => [],
              :after_lines   => []
              }
            ]
          }
        ]
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D91',
  'parse diff for renamed but unchanged file and newname is quoted' do
    lines = [
      'diff --git "a/sandbox/was_\\\\wa s_newfile_FIU" "b/sandbox/\\\\was_newfile_FIU"',
      'similarity index 100%',
      'rename from "sandbox/was_\\\\wa s_newfile_FIU"',
      'rename to "sandbox/\\\\was_newfile_FIU"'
    ].join("\n")

    expected =
    {
      'sandbox/\\was_newfile_FIU' => # <-- single backslash
      {
        :prefix_lines =>
        [
            'diff --git "a/sandbox/was_\\\\wa s_newfile_FIU" "b/sandbox/\\\\was_newfile_FIU"',
            'similarity index 100%',
            'rename from "sandbox/was_\\\\wa s_newfile_FIU"',
            'rename to "sandbox/\\\\was_newfile_FIU"',
        ],
        :was_filename => 'sandbox/was_\\wa s_newfile_FIU', # <-- single backslash
        :now_filename => 'sandbox/\\was_newfile_FIU', # <-- single backslash
        :chunks       => []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E38',
  'parse diff for renamed but unchanged file' do
    lines = [
      'diff --git a/sandbox/oldname b/sandbox/newname',
      'similarity index 100%',
      'rename from sandbox/oldname',
      'rename to sandbox/newname'
    ].join("\n")

    expected =
    {
      'sandbox/newname' =>
      {
        :prefix_lines =>
        [
            'diff --git a/sandbox/oldname b/sandbox/newname',
            'similarity index 100%',
            'rename from sandbox/oldname',
            'rename to sandbox/newname',
        ],
        :was_filename => 'sandbox/oldname',
        :now_filename => 'sandbox/newname',
        :chunks       => []
      }
    }

    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A61',
  "parse diff for renamed and changed file" do
    lines = [
      'diff --git a/sandbox/instructions b/sandbox/instructions_new',
      'similarity index 87%',
      'rename from sandbox/instructions',
      'rename to sandbox/instructions_new',
      'index e747436..83ec100 100644',
      '--- a/sandbox/instructions',
      '+++ b/sandbox/instructions_new',
      '@@ -6,4 +6,4 @@ For example, the potential anagrams of "biro" are',
      ' biro bior brio broi boir bori',
      ' ibro ibor irbo irob iobr iorb',
      ' rbio rboi ribo riob roib robi',
      '-obir obri oibr oirb orbi orib',
      '+obir obri oibr oirb orbi oribx'
    ].join("\n")

    expected_diff =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/instructions b/sandbox/instructions_new',
            'similarity index 87%',
            'rename from sandbox/instructions',
            'rename to sandbox/instructions_new',
            'index e747436..83ec100 100644'
          ],
          :was_filename => 'sandbox/instructions',
          :now_filename => 'sandbox/instructions_new',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 6, :size => 4 },
                :now => { :start_line => 6, :size => 4 },
              },
              :before_lines =>
                [
                  'biro bior brio broi boir bori',
                  'ibro ibor irbo irob iobr iorb',
                  'rbio rboi ribo riob roib robi'
                ],
              :sections =>
              [
                {
                  :deleted_lines => [ 'obir obri oibr oirb orbi orib' ],
                  :added_lines   => [ 'obir obri oibr oirb orbi oribx' ],
                  :after_lines   => []
                }, # section
              ] # sections
            } # chunk
          ] # chunks
    }

    expected = { 'sandbox/instructions_new' => expected_diff }
    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '91D',
  'parse diffs for two files' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index 896ddd8..2c8d1b8 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -1,7 +1,7 @@',
      ' aaa',
      ' bbb',
      ' ccc',
      '-ddd',
      '+eee',
      ' fff',
      ' ggg',
      ' hhh',
      'diff --git a/sandbox/other b/sandbox/other',
      'index cf0389a..b28bf03 100644',
      '--- a/sandbox/other',
      '+++ b/sandbox/other',
      '@@ -1,6 +1,6 @@',
      ' AAA',
      ' BBB',
      '-CCC',
      '-DDD',
      '+EEE',
      '+FFF',
      ' GGG',
      ' HHH',
      "\\ No newline at end of file"
    ].join("\n")

    expected_diff_1 =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/lines b/sandbox/lines',
            'index 896ddd8..2c8d1b8 100644'
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 7 },
                :now => { :start_line => 1, :size => 7 },
              },
              :before_lines => [ 'aaa', 'bbb', 'ccc'],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'ddd' ],
                  :added_lines   => [ 'eee' ],
                  :after_lines   => [ 'fff', 'ggg', 'hhh' ]
                }, # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected

    expected_diff_2 =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/other b/sandbox/other',
            'index cf0389a..b28bf03 100644'
          ],
        :was_filename => 'sandbox/other',
        :now_filename => 'sandbox/other',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 6 },
                :now => { :start_line => 1, :size => 6 },
              },
              :before_lines => [ 'AAA', 'BBB' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'CCC', 'DDD' ],
                  :added_lines   => [ 'EEE', 'FFF' ],
                  :after_lines   => [ 'GGG', 'HHH' ]
                }, # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected

    expected =
    {
      'sandbox/lines' => expected_diff_1,
      'sandbox/other' => expected_diff_2
    }

    parser = GitDiffParser.new(lines)
    assert_equal expected, parser.parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D56',
  'parse range was-size and now-size defaulted' do
    lines = '@@ -3 +5 @@'
    expected =
    {
      :was => { :start_line => 3, :size => 1 },
      :now => { :start_line => 5, :size => 1 },
    }
    assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AAA',
  'parse range was-size defaulted' do
    lines = '@@ -3 +5,9 @@'
    expected =
    {
      :was => { :start_line => 3, :size => 1 },
      :now => { :start_line => 5, :size => 9 },
    }
    assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '787',
  'parse range now-size defaulted' do
    lines = '@@ -3,4 +5 @@'
    expected =
    {
      :was => { :start_line => 3, :size => 4 },
      :now => { :start_line => 5, :size => 1 },
    }
    assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '64D',
  'parse range nothing defaulted' do
    lines = '@@ -3,4 +5,6 @@'
    expected =
    {
      :was => { :start_line => 3, :size => 4 },
      :now => { :start_line => 5, :size => 6 },
    }
    assert_equal expected, GitDiffParser.new(lines).parse_range
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A14',
  'parse no-newline-at-eof without leading backslash' do
    lines = ' No newline at eof'
    parser = GitDiffParser.new(lines)
    assert_equal 0, parser.n
    parser.parse_newline_at_eof
    assert_equal 0, parser.n
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9',
  'parse no-newline-at-eof with leading backslash' do
    lines = '\\ No newline at end of file'
    parser = GitDiffParser.new(lines)
    assert_equal 0, parser.n
    parser.parse_newline_at_eof
    assert_equal 1, parser.n
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1BC',
  'two chunks with no newline at end of file' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index b1a30d9..7fa9727 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -1,5 +1,5 @@',
      ' AAA',
      '-BBB',
      '+CCC',
      ' DDD',
      ' EEE',
      ' FFF',
      '@@ -8,6 +8,6 @@',
      ' PPP',
      ' QQQ',
      ' RRR',
      '-SSS',
      '+TTT',
      ' UUU',
      ' VVV',
      "\\ No newline at end of file"
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/lines b/sandbox/lines',
            'index b1a30d9..7fa9727 100644'
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 5 },
                :now => { :start_line => 1, :size => 5 },
              },
              :before_lines => [ 'AAA' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'BBB' ],
                  :added_lines   => [ 'CCC' ],
                  :after_lines   => [ 'DDD', 'EEE', 'FFF' ]
                }, # section
              ] # sections
            }, # chunk
            {
              :range =>
              {
                :was => { :start_line => 8, :size => 6 },
                :now => { :start_line => 8, :size => 6 },
              },
              :before_lines => [ 'PPP', 'QQQ', 'RRR' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'SSS' ],
                  :added_lines   => [ 'TTT' ],
                  :after_lines   => [ 'UUU', 'VVV' ]
                }, # section
              ] # sections
            }
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B2C',
  'diff one chunk one section' do
    lines = [
      '@@ -1,4 +1,4 @@',
      '-AAA',
      '+BBB',
      ' CCC',
      ' DDD',
      ' EEE'
    ].join("\n")

    expected =
    {
      :range =>
      {
        :was => { :start_line => 1, :size => 4 },
        :now => { :start_line => 1, :size => 4 },
      },
      :before_lines => [],
      :sections     =>
      [
        {
          :deleted_lines => [ 'AAA' ],
          :added_lines   => [ 'BBB' ],
          :after_lines   => [ 'CCC', 'DDD', 'EEE' ]
        }, # section
      ] # sections
    } # chunk

    assert_equal expected, GitDiffParser.new(lines).parse_chunk_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E9F',
  'diff one chunk two sections' do
    lines = [
      '@@ -1,8 +1,8 @@',
      ' AAA',
      ' BBB',
      '-CCC',
      '+DDD',
      ' EEE',
      '-FFF',
      '+GGG',
      ' HHH',
      ' JJJ',
      ' KKK'
    ].join("\n")

    expected =
      [
        {
          :range =>
          {
            :was => { :start_line => 1, :size => 8 },
            :now => { :start_line => 1, :size => 8 },
          },
          :before_lines => [ 'AAA', 'BBB' ],
          :sections     =>
          [
            {
              :deleted_lines => [ 'CCC' ],
              :added_lines   => [ 'DDD' ],
              :after_lines   => [ 'EEE' ]
            }, # section
            {
              :deleted_lines => [ 'FFF' ],
              :added_lines   => [ 'GGG' ],
              :after_lines   => [ 'HHH', 'JJJ', 'KKK' ]
            }, # section
          ] # sections
        } # chunk
      ] # chunks
    assert_equal expected, GitDiffParser.new(lines).parse_chunk_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A8A',
  'standard diff' do
    lines = [
      'diff --git a/sandbox/gapper.rb b/sandbox/gapper.rb',
      'index 26bc41b..8a5b0b7 100644',
      '--- a/sandbox/gapper.rb',
      '+++ b/sandbox/gapper.rb',
      '@@ -4,7 +5,8 @@ COMMENT',
      ' aaa',
      ' bbb',
      ' ',
      '-XXX',
      '+YYY',
      '+ZZZ',
      ' ccc',
      ' ddd',
      ' eee'
    ].join("\n")

    expected =
    {
      :prefix_lines =>
      [
        'diff --git a/sandbox/gapper.rb b/sandbox/gapper.rb',
        'index 26bc41b..8a5b0b7 100644'
      ],
      :was_filename => 'sandbox/gapper.rb',
      :now_filename => 'sandbox/gapper.rb',
      :chunks       =>
      [
        {
          :range =>
          {
            :was => { :start_line => 4, :size => 7 },
            :now => { :start_line => 5, :size => 8 },
          },
          :before_lines => [ 'aaa', 'bbb', '' ],
          :sections =>
          [
            { :deleted_lines => [ 'XXX' ],
              :added_lines => [ 'YYY', 'ZZZ' ],
              :after_lines => [ 'ccc', 'ddd', 'eee' ]
            }
          ]
        }
      ]
    }
    assert_equal expected, GitDiffParser.new(lines).parse_one
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
    assert_equal lines, GitDiffParser.new(all_lines).parse_prefix_lines
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C10',
  'diff two chunks' do
    lines = [
      'diff --git a/sandbox/test_gapper.rb b/sandbox/test_gapper.rb',
      'index 4d3ca1b..61e88f0 100644',
      '--- a/sandbox/test_gapper.rb',
      '+++ b/sandbox/test_gapper.rb',
      '@@ -9,4 +9,3 @@ class TestGapper < Test::Unit::TestCase',
      '-p Timw.now',
      '+p Time.now',
      "\\ No newline at end of file",
      '@@ -19,4 +19,3 @@ class TestGapper < Test::Unit::TestCase',
      '-q Timw.now',
      '+q Time.now'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/test_gapper.rb b/sandbox/test_gapper.rb',
            'index 4d3ca1b..61e88f0 100644'
          ],
        :was_filename => 'sandbox/test_gapper.rb',
        :now_filename => 'sandbox/test_gapper.rb',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 9, :size => 4 },
                :now => { :start_line => 9, :size => 3 },
              },
              :before_lines => [],
              :sections     =>
              [
                { :deleted_lines => [ 'p Timw.now' ],
                  :added_lines   => [ 'p Time.now' ],
                  :after_lines   => []
                }
              ]
            },
            {
              :range =>
              {
                :was => { :start_line => 19, :size => 4 },
                :now => { :start_line => 19, :size => 3 },
              },
              :before_lines => [],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'q Timw.now' ],
                  :added_lines   => [ 'q Time.now' ],
                  :after_lines   => []
                }
              ]
            }
          ]
    }
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD3',
  'when diffs are one line apart' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index 5ed4618..c47ec44 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -5,9 +5,9 @@',
      ' AAA',
      ' BBB',
      ' CCC',
      '-DDD',
      '+EEE',
      ' FFF',
      '-GGG',
      '+HHH',
      ' JJJ',
      ' KKK',
      ' LLL'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/lines b/sandbox/lines',
            'index 5ed4618..c47ec44 100644'
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 9 },
                :now => { :start_line => 5, :size => 9 },
              },
              :before_lines => [ 'AAA', 'BBB', 'CCC' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ],
                  :after_lines   => [ 'FFF' ]
                },
                {
                  :deleted_lines => [ 'GGG' ],
                  :added_lines   => [ 'HHH' ],
                  :after_lines   => [ 'JJJ', 'KKK', 'LLL' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D3C',
  'when diffs are 2 lines apart' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index 5ed4618..aad3f67 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -5,10 +5,10 @@',
      ' AAA',
      ' BBB',
      ' CCC',
      '-DDD',
      '+EEE',
      ' FFF',
      ' GGG',
      '-HHH',
      '+JJJ',
      ' KKK',
      ' LLL',
      ' MMM'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/lines b/sandbox/lines',
            'index 5ed4618..aad3f67 100644'
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 10 },
                :now => { :start_line => 5, :size => 10 },
              },
              :before_lines => [ 'AAA', 'BBB', 'CCC' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ],
                  :after_lines   => [ 'FFF', 'GGG' ]
                },
                {
                  :deleted_lines => [ 'HHH' ],
                  :added_lines   => [ 'JJJ' ],
                  :after_lines   => [ 'KKK', 'LLL', 'MMM' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '922',
  'when there is less than 7 unchanged lines',
  'between 2 changed lines',
  'they are merged into one chunk' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index 5ed4618..33d0e05 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -5,14 +5,14 @@',
      ' AAA',
      ' BBB',
      ' CCC',
      '-DDD',
      '+EEE',
      ' FFF',
      ' GGG',
      ' HHH',
      ' JJJ',
      ' KKK',
      ' LLL',
      '-MMM',
      '+NNN',
      ' OOO',
      ' PPP'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            "diff --git a/sandbox/lines b/sandbox/lines",
            "index 5ed4618..33d0e05 100644"
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 14 },
                :now => { :start_line => 5, :size => 14 },
              },
              :before_lines => [ 'AAA', 'BBB', 'CCC' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ],
                  :after_lines   => [ 'FFF', 'GGG', 'HHH', 'JJJ', 'KKK', 'LLL' ]
                },
                {
                  :deleted_lines => [ 'MMM' ],
                  :added_lines   => [ 'NNN' ],
                  :after_lines   => [ 'OOO', 'PPP' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '274',
  '7 unchanged lines between two changed lines',
  'creates two chunks' do
    lines = [
      'diff --git a/sandbox/lines b/sandbox/lines',
      'index 5ed4618..e78c888 100644',
      '--- a/sandbox/lines',
      '+++ b/sandbox/lines',
      '@@ -5,7 +5,7 @@',
      ' AAA',
      ' BBB',
      ' CCC',
      '-DDD',
      '+EEE',
      ' FFF',
      ' GGG',
      ' HHH',
      '@@ -13,7 +13,7 @@',
      ' QQQ',
      ' RRR',
      ' SSS',
      '-TTT',
      '+UUU',
      ' VVV',
      ' WWW',
      ' XXX'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/sandbox/lines b/sandbox/lines',
            'index 5ed4618..e78c888 100644'
          ],
        :was_filename => 'sandbox/lines',
        :now_filename => 'sandbox/lines',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 7 },
                :now => { :start_line => 5, :size => 7 },
              },
              :before_lines => [ 'AAA', 'BBB', 'CCC' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ],
                  :after_lines   => [ 'FFF', 'GGG', 'HHH' ]
                }
              ]
            },
            {
              :range =>
              {
                :was => { :start_line => 13, :size => 7 },
                :now => { :start_line => 13, :size => 7 },
              },
              :before_lines => [ 'QQQ', 'RRR', 'SSS' ],
              :sections     =>
              [
                {
                  :deleted_lines => [ 'TTT' ],
                  :added_lines   => [ 'UUU' ],
                  :after_lines   => [ 'VVV', 'WWW', 'XXX' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

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
      ' {',
      '     CHECK_TRUE(CircularBuffer_IsEmpty(buffer));',
      ' }',
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
        :prefix_lines =>
          [
            'diff --git a/sandbox/CircularBufferTest.cpp b/sandbox/CircularBufferTest.cpp',
            'index 0ddb952..a397f48 100644'
          ],
        :was_filename => 'sandbox/CircularBufferTest.cpp',
        :now_filename => 'sandbox/CircularBufferTest.cpp',
        :chunks       =>
          [
            {
              :range =>
              {
                :was => { :start_line => 35, :size => 3 },
                :now => { :start_line => 35, :size => 8 },
              },
              :before_lines =>
              [
                '{',
                '    CHECK_TRUE(CircularBuffer_IsEmpty(buffer));',
                '}'
              ],
              :sections =>
              [
                {
                  :deleted_lines => [],
                  :added_lines   =>
                  [
                    '',
                    'TEST(CircularBuffer, NotFullAfterCreation)',
                    '{',
                    '    CHECK_FALSE(CircularBuffer_IsFull(buffer));',
                    '}'
                  ],
                  :after_lines => []
                }
              ]
            }
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

end
