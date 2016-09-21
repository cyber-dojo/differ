
# NB: if you call this file app_test.rb then SimpleCov fails to see it?!

require_relative './lib_test_base'
require_relative './null_logger'

class GitDifferTest < LibTestBase

  def self.hex(suffix)
    '100' + suffix
  end

  def setup
    super
    ENV['DIFFER_CLASS_LOG'] = 'NullLogger'
  end

  # - - - - - - - - - - - - - - - - - - - -
  # corner case
  # - - - - - - - - - - - - - - - - - - - -

  test '38A',
  'empty was_files and empty now_files shows as benign nothing' do
    @was_files = {}
    @now_files = {}
    assert_diff []
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete
  # - - - - - - - - - - - - - - - - - - - -

  test '51A',
  'deleted empty file shows as delete file' do
    @was_files = { 'hiker.h' => '' }
    @now_files = { }
    assert_diff [
      'diff --git a/hiker.h b/hiker.h',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '369',
  'deleted non-empty file shows as delete file and all -deleted lines' do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { }
    assert_diff [
      'diff --git a/hiker.h b/hiker.h',
      'deleted file mode 100644',
      'index d68dd40..0000000',
      '--- a/hiker.h',
      '+++ /dev/null',
      '@@ -1,4 +0,0 @@',
      '-a',
      '-b',
      '-c',
      '-d'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '194',
  'all lines deleted but file not deleted shows as all -deleted lines' do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { 'hiker.h' => '' }
    assert_diff [
      'diff --git a/hiker.h b/hiker.h',
      'index d68dd40..e69de29 100644',
      '--- a/hiker.h',
      '+++ b/hiker.h',
      '@@ -1,4 +0,0 @@',
      '-a',
      '-b',
      '-c',
      '-d'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # add
  # - - - - - - - - - - - - - - - - - - - -

  test '45F',
  'added empty file shows as new file' do
    @was_files = { }
    @now_files = { 'diamond.h' => '' }
    assert_diff [
      'diff --git a/diamond.h b/diamond.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '991',
  'added non-empty file shows as all +added lines' do
    @was_files = { }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/diamond.h b/diamond.h',
      'new file mode 100644',
      'index 0000000..27a7ea6',
      '--- /dev/null',
      '+++ b/diamond.h',
      '@@ -0,0 +1,4 @@',
      '+a',
      '+b',
      '+c',
      '+d',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # no change
  # - - - - - - - - - - - - - - - - - - - -

  test '518',
  'unchanged empty-file has no diff' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'diamond.h' => '' }
    @now_files = { 'diamond.h' => '' }
    assert_diff []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '1DD',
  'unchanged non-empty file has no diff' do
    @was_files = { 'diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff []
  end

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test 'F9F',
  'change in non-empty file shows as +added and -deleted lines' do
    @was_files = { 'diamond.h' => 'a' }
    @now_files = { 'diamond.h' => 'b' }
    assert_diff [
      'diff --git a/diamond.h b/diamond.h',
      'index 2e65efe..63d8dbd 100644',
      '--- a/diamond.h',
      '+++ b/diamond.h',
      '@@ -1 +1 @@',
      '-a',
      '\\ No newline at end of file',
      '+b',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '6D7',
  'change in non-empty file shows as +added and -deleted lines',
  'with each chunk in its own indexed section' do
    @was_files = {
      'diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>', # no g
          '',
          'void diamond(char)', # no ;
          '',
          '#endif',
        ].join("\n")
    }
    @now_files = {
      'diamond.h' =>
        [
        '#ifndef DIAMOND',
        '#define DIAMOND',
        '',
        '#include <string>',
        '',
        'void diamond(char);',
        '',
        '#endif',
        ].join("\n")
    }
    assert_diff [
      'diff --git a/diamond.h b/diamond.h',
      'index a737c21..49a3313 100644',
      '--- a/diamond.h',
      '+++ b/diamond.h',
      '@@ -1,8 +1,8 @@',
      ' #ifndef DIAMOND',
      ' #define DIAMOND',
      ' ',
      '-#include <strin>',
      '+#include <string>',
      ' ',
      '-void diamond(char)',
      '+void diamond(char);',
      ' ',
      ' #endif',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # rename
  # - - - - - - - - - - - - - - - - - - - -

  test 'C06',
  'renamed file shows as similarity 100%' do
    # same as unchanged non-empty file except the filename
    # does not exist in was_files
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/hiker.h b/diamond.h',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to diamond.h'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '6BE',
  'renamed and slightly changed file shows as <100% similarity index' do
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }

    assert_diff [
      'diff --git a/hiker.h b/diamond.h',
      'similarity index 57%',
      'rename from hiker.h',
      'rename to diamond.h',
      'index 27a7ea6..2de4cc6 100644',
      '--- a/hiker.h',
      '+++ b/diamond.h',
      '@@ -1,4 +1,4 @@',
      ' a',
      ' b',
      '-c',
      '+X',
      ' d',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff(lines)
    lines = lines + [''] unless lines == []
    expected = lines.join("\n")
    actual = GitDiffer.new(@was_files, @now_files).diff
    assert_equal expected, actual
  end

end
