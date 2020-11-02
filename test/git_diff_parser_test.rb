require_relative 'differ_test_base'

class GitDiffParserTest < DifferTestBase

  def self.id58_prefix
    'B56'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -
  # parse_all
  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E10',
  'parse diff containing filename with backslash' do
    diff = [
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
                type: :deleted,
        old_filename: '\\was_newfile_FIU', # <-- single backslash
        new_filename: nil,
        lines:
        [
          section(0),
          deleted(1, 'Please rename me!'),
        ]
      }
    ]

    assert_equal expected, GitDiffParser.new(diff,lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '196',
  'parse diff deleted file' do
    diff = [
      'diff --git original original',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ].join("\n")

    expected =
    [
      {
                type: :deleted,
        old_filename: 'original',
        new_filename: nil,
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(diff,lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0FE',
  'parse another diff-form of a deleted file' do
    diff = [
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
                type: :deleted,
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

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D91',
  'parse diff for renamed but unchanged file and newname is quoted' do
    diff = [
      'diff --git "was_\\\\wa s_newfile_FIU" "\\\\was_newfile_FIU"',
      'similarity index 100%',
      'rename from "was_\\\\wa s_newfile_FIU"',
      'rename to "\\\\was_newfile_FIU"'
    ].join("\n")

    expected =
    [
      {
                type: :renamed,
        old_filename: 'was_\\wa s_newfile_FIU', # <-- single backslash
        new_filename: '\\was_newfile_FIU',      # <-- single backslash
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E38',
  'parse diff for renamed but unchanged file' do
    diff = [
      'diff --git oldname newname',
      'similarity index 100%',
      'rename from oldname',
      'rename to newname'
    ].join("\n")

    expected =
    [
      {
                type: :renamed,
        old_filename: 'oldname',
        new_filename: 'newname',
        lines: []
      }
    ]

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A61',
  "parse diff for renamed and changed file" do
    diff = [
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
                type: :renamed,
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

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '91D',
  'parse diffs for two files' do
    diff = [
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
                type: :changed,
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
                type: :changed,
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

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1BC',
  'two hunks with no newline at end of file' do
    diff = [
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
              type: :changed,
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

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B2C',
  'diff one-hunk one-line' do
    diff = [
      'diff --git lines lines',
      'index 72943a1..f761ec1 100644',
      '--- lines',
      '+++ lines',
      '@@ -1 +1 @@',
      '-aaa',
      '+bbb',
    ].join("\n")

    expected =
    {
              type: :changed,
      old_filename: 'lines',
      new_filename: 'lines',
      lines:
      [
        section(0),
        deleted(1, 'aaa'),
        added(1, 'bbb'),
      ]
    }

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A8A',
  'standard diff' do
    diff = [
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
              type: :changed,
      old_filename: 'gapper.rb',
      new_filename: 'gapper.rb',
      lines:
      [
        section(0),
        deleted(1, 'XXX'),
        added(1, 'YYY'),
        added(2, 'ZZZ'),
      ]
    }

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3B5',
  'find copies harder finds a rename' do
    diff = [
      'diff --git hiker.h diamond.h',
      'similarity index 99%',
      'rename from hiker.h',
      'rename to diamond.h',
      'index afcb4df..c0f407c 100644',
      '--- hiker.h',
      '+++ diamond.h'
    ]
    assert_equal diff, GitDiffParser.new(diff.join("\n")).parse_header
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '124',%w(
    renamed but unchanged file has no trailing
    --- or +++ lines and must not consume diff
    of following file as its header_lines
  ) do

    diff = [
      'diff --git hiker.h hiker.txt',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to hiker.txt',
      'diff --git wibble.c wibble.c',
      'index 75b325b..c41a0ce 100644',
      '--- wibble.c',
      '+++ wibble.c',
      '@@ -1,3 +1,4 @@',
      ' 111',
      ' 222',
      ' abc',
      '+ddd',
      '\\ No newline at end of file'
    ].join("\n")

    expected =
    {
              type: :renamed,
      old_filename: "hiker.h",
      new_filename: "hiker.txt",
      lines: []
    }

    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
  end

  private

  include GitDiffParserLib

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
