require_relative 'differ_test_base'
require_relative 'null_logger'
require_relative 'raising_disk_writer'
require_relative '../src/git_differ'

class GitDifferTest < DifferTestBase

  def self.hex_prefix
    '100'
  end

  def hex_setup
    externals.log = NullLogger.new(self)
  end

  # - - - - - - - - - - - - - - - - - - - -
  # exception safety
  # - - - - - - - - - - - - - - - - - - - -

  test 'B9F',
  'tmp dir is deleted if exception is raised' do
    externals.disk = RaisingDiskWriter.new(externals)
    was_files = { 'diamond.h' => 'a' } # ensure something to write
    now_files = {}
    differ = GitDiffer.new(self)
    raised = assert_raises(RuntimeError) { differ.diff(was_files, now_files) }
    assert_equal 'raising', raised.message
    dir = File.dirname(disk.pathed_filename)
    refute Dir.exist?(dir)
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

  test '68F', %w(
    deleted empty file in sub-dir
    shows as empty file in sub-dir
  ) do
    @was_files = { 'sub-dir/hiker.h' => '' }
    @now_files = { }
    assert_diff [
      'diff --git a/sub-dir/hiker.h b/sub-dir/hiker.h',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '505', %w(
    deleted empty-file in nested sub-dir
    shows as empty file in nested sub-dir
  ) do
    @was_files = { 'd1/d2/d3/d4/hiker.h' => '' }
    @now_files = { }
    assert_diff [
      'diff --git a/d1/d2/d3/d4/hiker.h b/d1/d2/d3/d4/hiker.h',
      'deleted file mode 100644',
      'index e69de29..0000000'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '369', %w(
    deleted non-empty file
    shows as deleted file and all -deleted lines
  ) do
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

  test '3C8', %w(
    deleted non-empty file in sub-dir
    shows as deleted file and all -deleted lines
  ) do
    @was_files = { 'dir/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { }
    assert_diff [
      'diff --git a/dir/hiker.h b/dir/hiker.h',
      'deleted file mode 100644',
      'index d68dd40..0000000',
      '--- a/dir/hiker.h',
      '+++ /dev/null',
      '@@ -1,4 +0,0 @@',
      '-a',
      '-b',
      '-c',
      '-d'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '97E', %w(
    deleted non-empty file in nested sub-dir
    shows as deleted file and all -deleted lines
  ) do
    @was_files = { '1/2/3/4/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { }
    assert_diff [
      'diff --git a/1/2/3/4/hiker.h b/1/2/3/4/hiker.h',
      'deleted file mode 100644',
      'index d68dd40..0000000',
      '--- a/1/2/3/4/hiker.h',
      '+++ /dev/null',
      '@@ -1,4 +0,0 @@',
      '-a',
      '-b',
      '-c',
      '-d'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '194', %w(
    all lines deleted but file not deleted
    shows as all -deleted lines
  ) do
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

  test 'E80', %w(
    all lines deleted but file in nested sub-dir not deleted
    shows as all -deleted lines
  ) do
    @was_files = { '3/2/1/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { '3/2/1/hiker.h' => '' }
    assert_diff [
      'diff --git a/3/2/1/hiker.h b/3/2/1/hiker.h',
      'index d68dd40..e69de29 100644',
      '--- a/3/2/1/hiker.h',
      '+++ b/3/2/1/hiker.h',
      '@@ -1,4 +0,0 @@',
      '-a',
      '-b',
      '-c',
      '-d'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '804', %w(
    all lines deleted but file in sub-dir not deleted
    shows as all -deleted lines
  ) do
    @was_files = { '1/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { '1/hiker.h' => '' }
    assert_diff [
      'diff --git a/1/hiker.h b/1/hiker.h',
      'index d68dd40..e69de29 100644',
      '--- a/1/hiker.h',
      '+++ b/1/hiker.h',
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

  test '41F', %w(
    added empty file in sub-dir
    shows as new file in sub-dir
  ) do
    @was_files = { }
    @now_files = { 'sub-dir/diamond.h' => '' }
    assert_diff [
      'diff --git a/sub-dir/diamond.h b/sub-dir/diamond.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '886', %w(
    added empty file in nested sub-dir
    shows as new file in nested sub-dir
  ) do
    @was_files = { }
    @now_files = { '1/2/3/4/diamond.h' => '' }
    assert_diff [
      'diff --git a/1/2/3/4/diamond.h b/1/2/3/4/diamond.h',
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

  test 'C91', %w(
    added non-empty file in sub-dir
    shows as all +added lines
  ) do
    @was_files = { }
    @now_files = { '4/diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/4/diamond.h b/4/diamond.h',
      'new file mode 100644',
      'index 0000000..27a7ea6',
      '--- /dev/null',
      '+++ b/4/diamond.h',
      '@@ -0,0 +1,4 @@',
      '+a',
      '+b',
      '+c',
      '+d',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B9B', %w(
    added non-empty file in nested sub-dir
    shows as all +added lines
  ) do
    @was_files = { }
    @now_files = { '1/2/3/4/diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/1/2/3/4/diamond.h b/1/2/3/4/diamond.h',
      'new file mode 100644',
      'index 0000000..27a7ea6',
      '--- /dev/null',
      '+++ b/1/2/3/4/diamond.h',
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

  test '519',
  'unchanged empty-file in sub-dir has no diff' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'x/diamond.h' => '' }
    @now_files = { 'x/diamond.h' => '' }
    assert_diff []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '520',
  'unchanged empty-file in nested sub-dir has no diff' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'x/y/z/diamond.h' => '' }
    @now_files = { 'x/y/z/diamond.h' => '' }
    assert_diff []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '1DD',
  'unchanged non-empty file has no diff' do
    @was_files = { 'diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff []
  end

  test '1DE',
  'unchanged non-empty file in sub-dir has no diff' do
    @was_files = { 'd/diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'd/diamond.h' => "a\nb\nc\nd" }
    assert_diff []
  end

  test '1DF',
  'unchanged non-empty file in nested sub-dir has no diff' do
    @was_files = { 'w/e/r/diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'w/e/r/diamond.h' => "a\nb\nc\nd" }
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

  test 'FA0',
  'change in non-empty file in sub-dir shows as +added and -deleted lines' do
    @was_files = { 'x/diamond.h' => 'a' }
    @now_files = { 'x/diamond.h' => 'b' }
    assert_diff [
      'diff --git a/x/diamond.h b/x/diamond.h',
      'index 2e65efe..63d8dbd 100644',
      '--- a/x/diamond.h',
      '+++ b/x/diamond.h',
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

  test '6D8', %w(
    change in non-empty file in sub-dir
    shows as +added and -deleted lines
    with each chunk in its own indexed section
  ) do
    @was_files = {
      'p/diamond.h' =>
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
      'p/diamond.h' =>
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
      'diff --git a/p/diamond.h b/p/diamond.h',
      'index a737c21..49a3313 100644',
      '--- a/p/diamond.h',
      '+++ b/p/diamond.h',
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

  test 'C07',
  'renamed file in sub-dir shows as similarity 100%' do
    # same as unchanged non-empty file except the filename
    # does not exist in was_files
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'x/diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/hiker.h b/x/diamond.h',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to x/diamond.h'
    ]
  end

  test 'C08',
  'renamed file in nested sub-dir shows as similarity 100%' do
    # same as unchanged non-empty file except the filename
    # does not exist in was_files
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'x/y/z/diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/hiker.h b/x/y/z/diamond.h',
      'similarity index 100%',
      'rename from hiker.h',
      'rename to x/y/z/diamond.h'
    ]
  end

  test 'C09',
  'renamed file across nested sub-dirs shows as similarity 100%' do
    # same as unchanged non-empty file except the filename
    # does not exist in was_files
    @was_files = { '1/2/3/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'x/y/z/diamond.h' => "a\nb\nc\nd" }
    assert_diff [
      'diff --git a/1/2/3/hiker.h b/x/y/z/diamond.h',
      'similarity index 100%',
      'rename from 1/2/3/hiker.h',
      'rename to x/y/z/diamond.h'
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

  test '6BF',%w(
    renamed and slightly changed file
    across nested sub-dirs shows as <100% similarity index
  ) do
    @was_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'x/y/diamond.h' => "a\nb\nX\nd" }

    assert_diff [
      'diff --git a/1/2/hiker.h b/x/y/diamond.h',
      'similarity index 57%',
      'rename from 1/2/hiker.h',
      'rename to x/y/diamond.h',
      'index 27a7ea6..2de4cc6 100644',
      '--- a/1/2/hiker.h',
      '+++ b/x/y/diamond.h',
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

  test '6C0',%w(
    renamed and unchanged file in sub-dir and
    changed file in base-dir
  ) do
    @was_files = {
      'a/hiker.h'   => "a\nb\nc\nd",
      'wibble.c'    => "123\nxyz\n"
    }
    @now_files = {
      'a/hiker.txt' => "a\nb\nc\nd",
      'wibble.c'    => "123\nxyz\n4"
    }

    assert_diff [
      'diff --git a/a/hiker.h b/a/hiker.txt',
      'similarity index 100%',
      'rename from a/hiker.h',
      'rename to a/hiker.txt',
      'diff --git a/wibble.c b/wibble.c',
      'index eff4ff4..2ca787d 100644',
      '--- a/wibble.c',
      '+++ b/wibble.c',
      '@@ -1,2 +1,3 @@',
      ' 123',
      ' xyz',
      '+4',
      '\\ No newline at end of file'
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff(lines)
    lines += [''] unless lines == []
    expected = lines.join("\n")
    actual = GitDiffer.new(self).diff(@was_files, @now_files)
    assert_equal expected, actual
  end

end
