require_relative 'differ_test_base'

class GitDiffParserTest < DifferTestBase

  def self.hex_prefix
    'B56'
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
    # double-quote " is a legal character in a linux filename
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
    # double-quote " is a legal character in a linux filename
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

  test 'AD7',
  'parse was & now filenames for new file in nested sub-dir' do
    prefix = [
       'diff --git a/1/2/3/empty.h b/1/2/3/empty.h',
       'new file mode 100644',
       'index 0000000..e69de29'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_nil was_filename, 'was_filename'
    assert_equal '1/2/3/empty.h', now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD8',
  'parse was & now filenames for renamed file in nested sub-dir' do
    diff_lines = [
      'diff --git a/1/2/3/old_name.h b/1/2/3/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 1/2/3/new_name.h'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', was_filename, 'was_filename'
    assert_equal '1/2/3/new_name.h', now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD9',
  'parse was & now filenames for renamed file across nested sub-dir' do
    diff_lines = [
      'diff --git a/1/2/3/old_name.h b/4/5/6/new_name.h',
      'similarity index 100%',
      'rename from 1/2/3/old_name.h',
      'rename to 4/5/6/new_name.h'
    ]
    was_filename, now_filename = GitDiffParser.new('').parse_was_now_filenames(diff_lines)
    assert_equal '1/2/3/old_name.h', was_filename, 'was_filename'
    assert_equal '4/5/6/new_name.h', now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD0', %w(
    parse was & now nested sub-dir filenames
    with double-quote and space in both filenames
  ) do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/s/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal "s/d/f/li n\"ux", was_filename, 'was_filename'
    assert_equal "u/i/o/em bed\"ded", now_filename, 'now_filename'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AD1', %w(
    parse was & now nested sub-dir filenames
    with double-quote and space in both filenames
    and where first sub-dir is 'a' or 'b' which could clash
    with git-diff output which uses a/ and b/
  ) do
    # double-quote " is a legal character in a linux filename
    prefix = [
       'diff --git "a/a/d/f/li n\"ux" "b/b/u/i/o/em bed\"ded"',
       'index 0000000..e69de29'
    ]
    was_filename,now_filename = GitDiffParser.new('').parse_was_now_filenames(prefix)
    assert_equal "a/d/f/li n\"ux", was_filename, 'was_filename'
    assert_equal "b/u/i/o/em bed\"ded", now_filename, 'now_filename'
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
        :prefix_lines =>
        [
            'diff --git "a/\\\\was_newfile_FIU" "b/\\\\was_newfile_FIU"',
            'deleted file mode 100644',
            'index 21984c7..0000000',
        ],
        :was_filename => '\\was_newfile_FIU', # <-- single backslash
        :now_filename => nil,
        :chunks =>
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
                :added_lines   => []
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
        :prefix_lines =>
        [
            'diff --git a/original b/original',
            'deleted file mode 100644',
            'index e69de29..0000000',
        ],
        :was_filename => 'original',
        :now_filename => nil,
        :chunks => []
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
        :prefix_lines =>
        [
            'diff --git a/untitled.rb b/untitled.rb',
            'deleted file mode 100644',
            'index 5c4b3ab..0000000',
        ],
        :was_filename => 'untitled.rb',
        :now_filename => nil,
        :chunks =>
        [
          {
            :range =>
            {
              :was => { :start_line => 1, :size       => 3 },
              :now => { :start_line => 0, :size       => 0 }
            },
            :sections     =>
            [
              {
                :deleted_lines => [ 'def answer', '  42', 'end'],
                :added_lines   => []
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
      'diff --git "a/was_\\\\wa s_newfile_FIU" "b/\\\\was_newfile_FIU"',
      'similarity index 100%',
      'rename from "was_\\\\wa s_newfile_FIU"',
      'rename to "\\\\was_newfile_FIU"'
    ].join("\n")

    expected =
    {
      '\\was_newfile_FIU' => # <-- single backslash
      {
        :prefix_lines =>
        [
            'diff --git "a/was_\\\\wa s_newfile_FIU" "b/\\\\was_newfile_FIU"',
            'similarity index 100%',
            'rename from "was_\\\\wa s_newfile_FIU"',
            'rename to "\\\\was_newfile_FIU"',
        ],
        :was_filename => 'was_\\wa s_newfile_FIU', # <-- single backslash
        :now_filename => '\\was_newfile_FIU', # <-- single backslash
        :chunks => []
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
      'diff --git a/oldname b/newname',
      'similarity index 100%',
      'rename from oldname',
      'rename to newname'
    ].join("\n")

    expected =
    {
      'newname' =>
      {
        :prefix_lines =>
        [
            'diff --git a/oldname b/newname',
            'similarity index 100%',
            'rename from oldname',
            'rename to newname',
        ],
        :was_filename => 'oldname',
        :now_filename => 'newname',
        :chunks => []
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
      'diff --git a/instructions b/instructions_new',
      'similarity index 87%',
      'rename from instructions',
      'rename to instructions_new',
      'index e747436..83ec100 100644',
      '--- a/instructions',
      '+++ b/instructions_new',
      '@@ -6,4 +6,4 @@ For example, the potential anagrams of "biro" are',
      '-obir obri oibr oirb orbi orib',
      '+obir obri oibr oirb orbi oribx'
    ].join("\n")

    expected_diff =
    {
        :prefix_lines =>
          [
            'diff --git a/instructions b/instructions_new',
            'similarity index 87%',
            'rename from instructions',
            'rename to instructions_new',
            'index e747436..83ec100 100644'
          ],
          :was_filename => 'instructions',
          :now_filename => 'instructions_new',
          :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 6, :size => 4 },
                :now => { :start_line => 6, :size => 4 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'obir obri oibr oirb orbi orib' ],
                  :added_lines   => [ 'obir obri oibr oirb orbi oribx' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    }

    expected = { 'instructions_new' => expected_diff }
    parser = GitDiffParser.new(lines)
    actual = parser.parse_all
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '91D',
  'parse diffs for two files' do
    lines = [
      'diff --git a/lines b/lines',
      'index 896ddd8..2c8d1b8 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -1,7 +1,7 @@',
      '-ddd',
      '+eee',
      'diff --git a/other b/other',
      'index cf0389a..b28bf03 100644',
      '--- a/other',
      '+++ b/other',
      '@@ -1,6 +1,6 @@',
      '-CCC',
      '-DDD',
      '+EEE',
      '+FFF',
      "\\ No newline at end of file"
    ].join("\n")

    expected_diff_1 =
    {
        :prefix_lines =>
          [
            'diff --git a/lines b/lines',
            'index 896ddd8..2c8d1b8 100644'
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 7 },
                :now => { :start_line => 1, :size => 7 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'ddd' ],
                  :added_lines   => [ 'eee' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected

    expected_diff_2 =
    {
        :prefix_lines =>
          [
            'diff --git a/other b/other',
            'index cf0389a..b28bf03 100644'
          ],
        :was_filename => 'other',
        :now_filename => 'other',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 6 },
                :now => { :start_line => 1, :size => 6 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'CCC', 'DDD' ],
                  :added_lines   => [ 'EEE', 'FFF' ]
                } # section
              ] # sections
            } # chunk
          ] # chunks
    } # expected

    expected =
    {
      'lines' => expected_diff_1,
      'other' => expected_diff_2
    }

    parser = GitDiffParser.new(lines)
    assert_equal expected, parser.parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_range
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
      'diff --git a/lines b/lines',
      'index b1a30d9..7fa9727 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -1,5 +1,5 @@',
      '-BBB',
      '+CCC',
      '@@ -8,6 +8,6 @@',
      '-SSS',
      '+TTT',
      "\\ No newline at end of file"
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/lines b/lines',
            'index b1a30d9..7fa9727 100644'
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 1, :size => 5 },
                :now => { :start_line => 1, :size => 5 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'BBB' ],
                  :added_lines   => [ 'CCC' ]
                } # section
              ] # sections
            }, # chunk
            {
              :range =>
              {
                :was => { :start_line => 8, :size => 6 },
                :now => { :start_line => 8, :size => 6 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'SSS' ],
                  :added_lines   => [ 'TTT' ]
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
      '+BBB'
    ].join("\n")

    expected =
    {
      :range =>
      {
        :was => { :start_line => 1, :size => 4 },
        :now => { :start_line => 1, :size => 4 },
      },
      :sections =>
      [
        {
          :deleted_lines => [ 'AAA' ],
          :added_lines   => [ 'BBB' ]
        } # section
      ] # sections
    } # chunk

    assert_equal expected, GitDiffParser.new(lines).parse_chunk_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E9F',
  'diff one chunk two sections' do
    lines = [
      '@@ -1,8 +1,8 @@',
      '-CCC',
      '+DDD',
      '-FFF',
      '+GGG'
    ].join("\n")

    expected =
      [
        {
          :range =>
          {
            :was => { :start_line => 1, :size => 8 },
            :now => { :start_line => 1, :size => 8 },
          },
          :sections =>
          [
            {
              :deleted_lines => [ 'CCC' ],
              :added_lines   => [ 'DDD' ]
            }, # section
            {
              :deleted_lines => [ 'FFF' ],
              :added_lines   => [ 'GGG' ]
            } # section
          ] # sections
        } # chunk
      ] # chunks
    assert_equal expected, GitDiffParser.new(lines).parse_chunk_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A8A',
  'standard diff' do
    lines = [
      'diff --git a/gapper.rb b/gapper.rb',
      'index 26bc41b..8a5b0b7 100644',
      '--- a/gapper.rb',
      '+++ b/gapper.rb',
      '@@ -4,7 +5,8 @@ COMMENT',
      '-XXX',
      '+YYY',
      '+ZZZ'
    ].join("\n")

    expected =
    {
      :prefix_lines =>
      [
        'diff --git a/gapper.rb b/gapper.rb',
        'index 26bc41b..8a5b0b7 100644'
      ],
      :was_filename => 'gapper.rb',
      :now_filename => 'gapper.rb',
      :chunks =>
      [
        {
          :range =>
          {
            :was => { :start_line => 4, :size => 7 },
            :now => { :start_line => 5, :size => 8 },
          },
          :sections =>
          [
            { :deleted_lines => [ 'XXX' ],
              :added_lines => [ 'YYY', 'ZZZ' ]
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
      'diff --git a/test_gapper.rb b/test_gapper.rb',
      'index 4d3ca1b..61e88f0 100644',
      '--- a/test_gapper.rb',
      '+++ b/test_gapper.rb',
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
            'diff --git a/test_gapper.rb b/test_gapper.rb',
            'index 4d3ca1b..61e88f0 100644'
          ],
        :was_filename => 'test_gapper.rb',
        :now_filename => 'test_gapper.rb',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 9, :size => 4 },
                :now => { :start_line => 9, :size => 3 },
              },
              :sections =>
              [
                { :deleted_lines => [ 'p Timw.now' ],
                  :added_lines   => [ 'p Time.now' ]
                }
              ]
            },
            {
              :range =>
              {
                :was => { :start_line => 19, :size => 4 },
                :now => { :start_line => 19, :size => 3 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'q Timw.now' ],
                  :added_lines   => [ 'q Time.now' ]
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
      'diff --git a/lines b/lines',
      'index 5ed4618..c47ec44 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,9 +5,9 @@',
      '-DDD',
      '+EEE',
      '-GGG',
      '+HHH'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/lines b/lines',
            'index 5ed4618..c47ec44 100644'
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 9 },
                :now => { :start_line => 5, :size => 9 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ]
                },
                {
                  :deleted_lines => [ 'GGG' ],
                  :added_lines   => [ 'HHH' ]
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
      'diff --git a/lines b/lines',
      'index 5ed4618..aad3f67 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,10 +5,10 @@',
      '-DDD',
      '+EEE',
      '-HHH',
      '+JJJ'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/lines b/lines',
            'index 5ed4618..aad3f67 100644'
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 10 },
                :now => { :start_line => 5, :size => 10 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ]
                },
                {
                  :deleted_lines => [ 'HHH' ],
                  :added_lines   => [ 'JJJ' ]
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
      'diff --git a/lines b/lines',
      'index 5ed4618..33d0e05 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,14 +5,14 @@',
      '-DDD',
      '+EEE',
      '-MMM',
      '+NNN'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            "diff --git a/lines b/lines",
            "index 5ed4618..33d0e05 100644"
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 14 },
                :now => { :start_line => 5, :size => 14 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ]
                },
                {
                  :deleted_lines => [ 'MMM' ],
                  :added_lines   => [ 'NNN' ]
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
      'diff --git a/lines b/lines',
      'index 5ed4618..e78c888 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,7 +5,7 @@',
      '-DDD',
      '+EEE',
      '@@ -13,7 +13,7 @@',
      '-TTT',
      '+UUU'
    ].join("\n")

    expected =
    {
        :prefix_lines =>
          [
            'diff --git a/lines b/lines',
            'index 5ed4618..e78c888 100644'
          ],
        :was_filename => 'lines',
        :now_filename => 'lines',
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 5, :size => 7 },
                :now => { :start_line => 5, :size => 7 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'DDD' ],
                  :added_lines   => [ 'EEE' ]
                }
              ]
            },
            {
              :range =>
              {
                :was => { :start_line => 13, :size => 7 },
                :now => { :start_line => 13, :size => 7 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [ 'TTT' ],
                  :added_lines   => [ 'UUU' ]
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
        :chunks =>
          [
            {
              :range =>
              {
                :was => { :start_line => 35, :size => 3 },
                :now => { :start_line => 35, :size => 8 },
              },
              :sections =>
              [
                {
                  :deleted_lines => [],
                  :added_lines =>
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
          ] # chunks
    } # expected
    assert_equal expected, GitDiffParser.new(lines).parse_one
  end

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
      '+4',
      '\\ No newline at end of file'
    ].join("\n")

    expected_diff_1 =
    {
      :prefix_lines =>
      [
        "diff --git a/hiker.h b/hiker.txt",
        "similarity index 100%",
        "rename from hiker.h",
        "rename to hiker.txt",
      ],
      :was_filename => "hiker.h",
      :now_filename => "hiker.txt",
      :chunks => []
    }
    expected_diff_2 =
    {
      :prefix_lines =>
      [
        'diff --git a/wibble.c b/wibble.c',
        'index eff4ff4..2ca787d 100644'
      ],
      :was_filename => 'wibble.c',
      :now_filename => 'wibble.c',
      :chunks =>
      [
        {
          :range =>
          {
            :was => { :start_line => 1, :size => 2 },
            :now => { :start_line => 1, :size => 3 }
          },
          :sections =>
          [
            {
              :deleted_lines => [],
              :added_lines   => ['4']
            }
          ]
        }
      ]
    }

    expected_diffs =
    {
      'hiker.txt' => expected_diff_1,
      'wibble.c'  => expected_diff_2
    }

    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    assert_equal expected_diffs, actual_diffs
  end

end
