require_relative 'differ_test_base'
class GitDiffParserTest < DifferTestBase
  def self.hex_prefix; 'B56'; end
    # double-quote " is a legal character in a linux filename
    # double-quote " is a legal character in a linux filename
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
      ' 123',
      ' xyz',
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
        "diff --git a/wibble.c b/wibble.c",
        "index eff4ff4..2ca787d 100644"
      ],
      :was_filename => "wibble.c",
      :now_filename => "wibble.c",
      :chunks =>
      [
        {
          :range =>
          {
            :was => { :start_line => 1, :size => 2 },
            :now => { :start_line => 1, :size => 3 }
          },
          :before_lines => ["123", "xyz"],
          :sections =>
          [
            {
              :deleted_lines => [],
              :added_lines   => ["4"],
              :after_lines   => []
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
