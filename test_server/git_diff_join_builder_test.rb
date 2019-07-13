require_relative 'differ_test_base'
require_relative '../src/git_diff_join_builder'

class GitDiffJoinBuilderTest < DifferTestBase

  include GitDiffJoinBuilder

  def self.hex_prefix
    'A33'
  end

  test '2D7',
  'hunk with a space in its filename' do

    @diff_lines =
    [
      'diff --git a/file with_space b/file with_space',
      'new file mode 100644',
      'index 0000000..21984c7',
      '--- /dev/null',
      '+++ b/file with_space',
      '@@ -0,0 +1 @@',
      '+Please rename me!',
      '\\ No newline at end of file'
    ]

    @source_lines =
    [
      'Please rename me!'
    ]

    @expected =
    [
      section(0),
      added('Please rename me!', 1),
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'F3C',
  'hunk with defaulted now line info' do

    @diff_lines =
    [
      'diff --git a/untitled_5G3 b/untitled_5G3',
      'index e69de29..2e65efe 100644',
      '--- a/untitled_5G3',
      '+++ b/untitled_5G3',
      '@@ -0,0 +1 @@',
      '+aaa',
      '\\ No newline at end of file'
    ]

    @source_lines =
    [
      'aaa'
    ]

    @expected =
    [
      section(0),
      added('aaa', 1),
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'F10',
    'two hunks with leading and trailing',
    'same lines and no newline at eof' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index b1a30d9..7fa9727 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -2,1 +2,1 @@',
      '-bbb',
      '+ccc',
      '@@ -11,1 +11,1 @@',
      '-qqq',
      '+rrr',
      '\\ No newline at end of file'
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh',
      'nnn',
      'ooo',
      'ppp',
      'qqq',
      'sss',
      'ttt'
    ]

    @expected =
    [
      same('aaa', 1),
      section(0),
      deleted('bbb', 2),
      added('ccc', 2),
      same('ddd',  3),
      same('eee',  4),
      same('fff',  5),
      same('ggg',  6),
      same('hhh',  7),
      same('nnn',  8),
      same('ooo',  9),
      same('ppp', 10),
      section(1),
      deleted('qqq', 11),
      added('rrr', 11),
      same('sss', 12),
      same('ttt', 13)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '1C8',
    'one hunk with deleted only lines, one hunk with added only lines' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 0719398..2943489 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -1,2 +0,0 @@',
      '-aaa',
      '-bbb',
      '@@ -0,0 +9,2 @@',
      '+uuu',
      '+vvv'
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'ppp',
      'qqq',
      'rrr',
      'ttt'
    ]

    @expected =
    [
      section(0),
      deleted('aaa', 1),
      deleted('bbb', 2),
      same('ccc', 2),
      same('ddd', 3),
      same('eee', 4),
      same('fff', 5),
      same('ppp', 6),
      same('qqq', 7),
      same('rrr', 8),
      same('ttt', 9),
      section(1),
      added('uuu', 8),
      added('vvv', 9)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'C58',
    'one hunk with two sections',
    'each with one line added and one line deleted' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 535d2b0..a173ef1 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -3 +3 @@ bbb',
      '-ccc',
      '+ddd',
      '@@ -5 +5 @@ eee',
      '-fff',
      '+ggg',
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ddd',
      'eee',
      'ggg',
      'hhh',
      'iii',
      'jjj'
    ]

    @expected =
    [
      same('aaa', 1),
      same('bbb', 2),
      section(0),
      deleted('ccc', 3),
      added('ddd', 3),
      same('eee', 4),
      section(1),
      deleted('fff', 5),
      added('ggg', 5),
      same('hhh', 6),
      same('iii', 7),
      same('jjj', 8)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '56A',
  'one hunk with one section with only lines added' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 06e567b..59e88aa 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -1,6 +1,9 @@',
      ' aaa',
      ' bbb',
      ' ccc',
      '+ddd',
      '+eee',
      '+fff',
      ' ggg',
      ' hhh',
      ' iii'
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh',
      'iii',
      'jjj'
    ]

    @expected =
    [
      same('aaa', 1),
      same('bbb', 2),
      same('ccc', 3),
      section(0),
      added('ddd', 4),
      added('eee', 5),
      added('fff', 6),
      same('ggg', 7),
      same('hhh', 8),
      same('iii', 9),
      same('jjj', 10)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'FA0',
  'one hunk with one section with only lines deleted' do
    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 0b669b6..a972632 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,2 +4,0 @@ ddd',
      '-EEE',
      '-FFF'
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'ggg',
      'hhh',
      'iii',
      'jjj'
    ]

    @expected =
    [
      same('aaa', 1),
      same('bbb', 2),
      same('ccc', 3),
      same('ddd', 4),
      section(0),
      deleted('EEE', 5),
      deleted('FFF', 6),
      same('ggg', 5),
      same('hhh', 6),
      same('iii', 7),
      same('jjj', 8)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'ED0',
    'one hunk with one section',
    'with more lines deleted than added' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 08fe19c..1f8695e 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -3,9 +3,7 @@',
      ' ddd',
      ' eee',
      ' fff',
      '-ggg',
      '-hhh',
      '-iii',
      '+jjj',
      ' kkk',
      ' lll',
      ' mmm'
    ]

    @source_lines =
    [
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'jjj',
      'kkk',
      'lll',
      'mmm',
      'nnn'
    ]

    @expected =
    [
      same('bbb', 1),
      same('ccc', 2),
      same('ddd', 3),
      same('eee', 4),
      same('fff', 5),
      section(0),
      deleted('ggg', 6),
      deleted('hhh', 7),
      deleted('iii', 8),
      added('jjj', 6),
      same('kkk', 7),
      same('lll', 8),
      same('mmm', 9),
      same('nnn', 10)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'CAD',
    'one hunk with one section',
    'with more lines added than deleted' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 8e435da..a787223 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -3,7 +3,8 @@',
      ' ccc',
      ' ddd',
      ' eee',
      '-fff',
      '+XXX',
      '+YYY',
      ' ggg',
      ' hhh',
      ' iii'
    ]

    @source_lines =
    [
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'XXX',
      'YYY',
      'ggg',
      'hhh',
      'iii',
      'jjj',
      'kkk',
      'lll',
      'mmm'
    ]

    @expected =
    [
      same('aaa', 1),
      same('bbb', 2),
      same('ccc', 3),
      same('ddd', 4),
      same('eee', 5),
      section(0),
      deleted('fff', 6),
      added('XXX',6),
      added('YYY',7),
      same('ggg',   8),
      same('hhh',   9),
      same('iii',  10),
      same('jjj', 11),
      same('kkk', 12),
      same('lll', 13),
      same('mmm',14),
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '951',
    'one hunk with one section',
    'with one line deleted and one line added' do

    @diff_lines =
    [
      'diff --git a/lines b/lines',
      'index 5ed4618..aad3f67 100644',
      '--- a/lines',
      '+++ b/lines',
      '@@ -5,7 +5,7 @@',
      ' aaa',
      ' bbb',
      ' ccc',
      '-QQQ',
      '+RRR',
      ' ddd',
      ' eee',
      ' fff'
    ]

    @source_lines =
    [
      'zz',
      'yy',
      'xx',
      'ww',
      'aaa',
      'bbb',
      'ccc',
      'RRR',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh'
    ]

    @expected =
    [
      same('zz', 1),
      same('yy', 2),
      same('xx', 3),
      same('ww', 4),
      same('aaa', 5),
      same('bbb', 6),
      same('ccc', 7),
      section(0),
      deleted('QQQ', 8),
      added('RRR', 8),
      same('ddd',   9),
      same('eee', 10),
      same('fff', 11),
      same('ggg', 12),
      same('hhh', 13)
    ]

    assert_equal_builder
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def assert_equal_builder
    diff = GitDiffParser.new(@diff_lines.join("\n")).parse_one
    actual = git_diff_join_builder(diff, @source_lines)
    #puts "@expected:#{@expected.class.name}:#{@expected}:"
    #puts "   actual:#{actual.class.name}:#{actual}:"
    assert_equal @expected, actual, "sdsdsd"
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def section(index)
    { :type => :section, index:index }
  end

  def same(line, number)
    src(:same, line, number)
  end

  def deleted(line, number)
    src(:deleted, line, number)
  end

  def added(line, number)
    src(:added, line, number)
  end

  def src(type, line, number)
    { type:type, line:line, number:number }
  end

end
