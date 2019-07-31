    assert_equal 'e mpty.h', old_filename, :old_filename
    assert_equal 'e mpty.h', new_filename, :new_filename
    assert_equal "li n\"ux",    old_filename, :old_filename
    assert_equal "em bed\"ded", new_filename, :new_filename
    assert_equal 'plain',       old_filename, :old_filename
    assert_equal "em bed\"ded", new_filename, :new_filename
    assert_equal "emb ed\"ded", old_filename, :old_filename
    assert_equal 'plain',       new_filename, :new_filename
    assert_equal 'Deleted.java', old_filename, :old_filename
    assert_equal 'empty.h', new_filename, :new_filename
    assert_equal 'old_name.h',   old_filename, :old_filename
    assert_equal "new \"name.h", new_filename, :new_filename
    assert_equal '1/2/3/empty.h', new_filename, :new_filename
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '1/2/3/new_name.h', new_filename, :new_filename
    assert_equal '1/2/3/old_name.h', old_filename, :old_filename
    assert_equal '4/5/6/new_name.h', new_filename, :new_filename
    assert_equal "s/d/f/li n\"ux",    old_filename, :old_filename
    assert_equal "u/i/o/em bed\"ded", new_filename, :new_filename
    assert_equal "a/d/f/li n\"ux",      old_filename, :old_filename
    assert_equal "b/u/i/o/em bed\"ded", new_filename, :new_filename
        lines:
          section(0),
          deleted(1, 'Please rename me!'),
    assert_equal expected, GitDiffParser.new(lines).parse_all
        lines: []
    assert_equal expected, GitDiffParser.new(lines).parse_all
        lines:
          section(0),
          deleted(1, 'def answer'),
          deleted(2, '  42'),
          deleted(3, 'end'),
    assert_equal expected, GitDiffParser.new(lines).parse_all
        lines: []
    assert_equal expected, GitDiffParser.new(lines).parse_all
        lines: []
    assert_equal expected, GitDiffParser.new(lines).parse_all
      'index dc12fc4..08a6241 100644',
      '@@ -1,10 +1,10 @@',
      ' Write a program to generate all potential',
      ' anagrams of an input string.',
      ' ',
      ' For example, the potential anagrams of "biro" are',
      ' ',
      ' biro bior brio broi boir bori',
      ' ibro ibor irbo irob iobr iorb',
      ' rbio rboi ribo riob roib robi',
      '+obir obri oibr oirb orbi oribx',
      ' ',
        lines:
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
    assert_equal expected, GitDiffParser.new(lines).parse_all
      'index 1d60b70..14fc1c2 100644',
      '@@ -1 +1 @@',
      'index f72fee1..9b29445 100644',
      '@@ -1,4 +1,4 @@',
      ' AAA',
      ' BBB',
        lines:
          section(0),
          deleted(1, 'ddd'),
          added(1, 'eee'),
        lines:
          same(1, 'AAA'),
          same(2, 'BBB'),
          section(0),
          deleted(3, 'CCC'),
          deleted(4, 'DDD'),
          added(3, 'EEE'),
          added(4, 'FFF'),
    assert_equal expected, GitDiffParser.new(lines).parse_all
      'index f70c2c0..ba0f878 100644',
      '@@ -1,4 +1,5 @@',
      ' aaa',
      '-bbb',
      '+BBB',
      ' ccc',
      ' ddd',
      '+EEE',
      '\ No newline at end of file',
      lines:
        same(1, 'aaa'),
        section(0),
        deleted(2, 'bbb'),
        added(2, 'BBB'),
        same(3, 'ccc'),
        same(4, 'ddd'),
        section(1),
        added(5, 'EEE'),
    assert_equal expected, GitDiffParser.new(lines).parse_one
      'diff --git lines lines',
      'index 72943a1..f761ec1 100644',
      '--- lines',
      '+++ lines',
      '@@ -1 +1 @@',
      '-aaa',
      '+bbb',
      old_filename: 'lines',
      new_filename: 'lines',
      lines:
      [
        section(0),
        deleted(1, 'aaa'),
        added(1, 'bbb'),
      ]
    assert_equal expected, GitDiffParser.new(lines).parse_one
      lines:
        section(0),
        deleted(1, 'XXX'),
        added(1, 'YYY'),
        added(2, 'ZZZ'),
    assert_equal expected, GitDiffParser.new(lines).parse_one
    assert_equal lines, GitDiffParser.new(lines.join("\n")).parse_header
      'index 75b325b..c41a0ce 100644',
      '@@ -1,3 +1,4 @@',
      ' 111',
      ' 222',
      ' abc',
      '+ddd',
    {
      old_filename: "hiker.h",
      new_filename: "hiker.txt",
      lines: []
    }

    assert_equal expected, GitDiffParser.new(diff_lines).parse_one
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