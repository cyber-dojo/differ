require_relative 'client_test_base'

class DifferClientTest < ClientTestBase

  def self.hex_prefix
    '200'
  end

  # - - - - - - - - - - - - - - - - - - - -
  # >10K query was a problem for thin at one time
  # - - - - - - - - - - - - - - - - - - - -

  test '347',
  '>10K query is not rejected by thin' do
    @old_files = { 'wibble.h' => 'X'*45*1024 }
    @new_files = {}
    json = get_diff
    refute_nil json['wibble.h']
  end

  test '348',
  '>10K query in nested sub-dir is not rejected by thin' do
    @old_files = { 'gh/jk/wibble.h' => 'X'*45*1024 }
    @new_files = {}
    json = get_diff
    refute_nil json['gh/jk/wibble.h']
  end

  # - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - -

  test '945', 'sha 200' do
    sha = differ.sha
    assert_equal 40, sha.size, 'sha.size'
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch), ch
    end
  end

  # - - - - - - - - - - - - - - - - - - - -
  # alive?
  # - - - - - - - - - - - - - - - - - - - -

  test '946', 'alive? 200' do
    assert differ.alive?
  end

  # - - - - - - - - - - - - - - - - - - - -
  # ready?
  # - - - - - - - - - - - - - - - - - - - -

  test '947', 'ready? 200' do
    assert differ.ready?
  end

  # - - - - - - - - - - - - - - - - - - - -
  # failure cases
  # - - - - - - - - - - - - - - - - - - - -

  test '7C0', %w( calling unknown method raises ) do
    requester = HttpJson::RequestPacker.new(externals.http, 'differ-server', 4567)
    http = HttpJson::ResponseUnpacker.new(requester, DifferException)
    error = assert_raises(DifferException) { http.get(:shar, {"x":42}) }
    json = JSON.parse(error.message)
    assert_equal '/shar', json['path']
    assert_equal '{"x":42}', json['body']
    assert_equal 'DifferService', json['class']
    assert_equal 'unknown path', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete file
  # - - - - - - - - - - - - - - - - - - - -

  test '313',
  'deleted empty file shows as empty array' do
    @old_files = { 'hiker.h' => '' }
    @new_files = { }
    assert_diff 'hiker.h', []
  end

  test '314',
  'deleted empty file in nested sub-dir shows as empty array' do
    @old_files = { '6/7/8/hiker.h' => '' }
    @new_files = { }
    assert_diff '6/7/8/hiker.h', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FE9',
  'deleted non-empty file shows as all lines deleted' do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
    assert_diff 'hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd')
    ]
  end

  test 'FEA',
  'deleted non-empty file in nested sub-dir shows as all lines deleted' do
    @old_files = { '4/5/6/7/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
    assert_diff '4/5/6/7/hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete content
  # - - - - - - - - - - - - - - - - - - - -

  test 'B67',
  'all lines deleted but file not deleted',
  'shows as all lines deleted' do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'hiker.h' => '' }
    assert_diff 'hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd'),
    ]
  end

  test 'B68',
  'all lines deleted but nested sub-dir file not deleted',
  'shows as all lines deleted' do
    @old_files = { 'r/t/y/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'r/t/y/hiker.h' => '' }
    assert_diff 'r/t/y/hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd'),
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # new file
  # - - - - - - - - - - - - - - - - - - - -

  test '95F',
  %w( added empty file shows as [''] ) do
    @old_files = { }
    @new_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ added(1,'') ]
  end

  test '960',
  %w( added empty file in nested sub-dir shows as [''] ) do
    @old_files = { }
    @new_files = { 'a/b/c/diamond.h' => '' }
    assert_diff 'a/b/c/diamond.h', [ added(1,'') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2C3',
  'added non-empty file shows as all lines added' do
    @old_files = { }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
      section(0),
      added(1, 'a'),
      added(2, 'b'),
      added(3, 'c'),
      added(4, 'd')
    ]
  end

  test '2C4',
  'added non-empty file in nested sub-dir shows as all lines added' do
    @old_files = { }
    @new_files = { 'q/w/e/diamond.h' => "a\nb\nc\nd" }
    assert_diff 'q/w/e/diamond.h', [
      section(0),
      added(1, 'a'),
      added(2, 'b'),
      added(3, 'c'),
      added(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # no change
  # - - - - - - - - - - - - - - - - - - - -

  test 'AEC',
  'empty old_files and empty new_files is benign no-op' do
    assert_equal({}, differ.diff(test_id,{},{}))
  end

  test '7FE',
  'unchanged empty-file shows as one empty line' do
    # same as adding an empty file except in this case
    # the filename exists in old_files
    @old_files = { 'diamond.h' => '' }
    @new_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1,'') ]
  end

  test '7FF',
  'unchanged empty-file in nested sub-dir shows as one empty line' do
    # same as adding an empty file except in this case
    # the filename exists in old_files
    @old_files = { 'w/e/r/diamond.h' => '' }
    @new_files = { 'w/e/r/diamond.h' => '' }
    assert_diff 'w/e/r/diamond.h', [ same(1,'') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '365',
  'unchanged non-empty file shows as all lines same' do
    @old_files = { 'diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
      same(1, 'a'),
      same(2, 'b'),
      same(3, 'c'),
      same(4, 'd')
    ]
  end

  test '366',
  'unchanged non-empty file in nested sub-dir shows as all lines same' do
    @old_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    @new_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    assert_diff 'r/t/y/diamond.h', [
      same(1, 'a'),
      same(2, 'bb'),
      same(3, 'c'),
      same(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test 'E3E',
  'changed non-empty file shows as deleted and added lines' do
    @old_files = { 'diamond.h' => 'a' }
    @new_files = { 'diamond.h' => 'b' }
    assert_diff 'diamond.h', [
      section(0),
      deleted(1, 'a'),
      added(  1, 'b')
    ]
  end

  test 'E3F',
  'changed non-empty file in nested sub-dir shows as deleted and added lines' do
    @old_files = { 't/y/u/diamond.h' => 'a1' }
    @new_files = { 't/y/u/diamond.h' => 'b2' }
    assert_diff 't/y/u/diamond.h', [
      section(0),
      deleted(1, 'a1'),
      added(  1, 'b2')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B9E',
  'changed non-empty file shows as deleted and added lines',
  'with each hunk in its own indexed section' do
    @old_files = {
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
    @new_files = {
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
    assert_diff 'diamond.h', [
      same(   1, '#ifndef DIAMOND'),
      same(   2, '#define DIAMOND'),
      same(   3, ''),

      section(0),
      deleted(4, '#include <strin>'),
      added(  4, '#include <string>'),
      same(   5, ''),

      section(1),
      deleted(6, 'void diamond(char)'),
      added(  6, 'void diamond(char);'),
      same(   7, ''),
      same(   8, '#endif'),
    ]
  end

  test 'B9F',
  'changed non-empty file in nested sub-dir shows as deleted and added lines',
  'with each hunk in its own indexed section' do
    @old_files = {
      'a/b/c/diamond.h' =>
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
    @new_files = {
      'a/b/c/diamond.h' =>
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
    assert_diff 'a/b/c/diamond.h', [
      same(   1, '#ifndef DIAMOND'),
      same(   2, '#define DIAMOND'),
      same(   3, ''),

      section(0),
      deleted(4, '#include <strin>'),
      added(  4, '#include <string>'),
      same(   5, ''),

      section(1),
      deleted(6, 'void diamond(char)'),
      added(  6, 'void diamond(char);'),
      same(   7, ''),
      same(   8, '#endif'),
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # rename
  # - - - - - - - - - - - - - - - - - - - -

  test 'E50',
  'renamed file shows as all lines same' do
    # same as unchanged non-empty file except the filename
    # does not exist in old_files
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
      same(1, 'a'),
      same(2, 'b'),
      same(3, 'c'),
      same(4, 'd')
    ]
  end

  test 'E51',
  'renamed file in nested sub-dir shows as all lines same' do
    # same as unchanged non-empty file except the filename
    # does not exist in old_files
    @old_files = { 'a/f/d/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/f/d/diamond.h' => "a\nb\nc\nd" }
    assert_diff 'a/f/d/diamond.h', [
      same(1, 'a'),
      same(2, 'b'),
      same(3, 'c'),
      same(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FDB',
  'renamed and slightly changed file shows as mostly same lines' do
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff 'diamond.h', [
      same(   1, 'a'),
      same(   2, 'b'),
      section(0),
      deleted(3, 'c'),
      added(  3, 'X'),
      same(   4, 'd')
    ]
  end

  test 'FDC',
  'renamed and slightly changed file in nested sub-dir shows as mostly same lines' do
    @old_files = { 'a/b/c/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/b/c/diamond.h' => "a\nb\nX\nd" }
    assert_diff 'a/b/c/diamond.h', [
      same(   1, 'a'),
      same(   2, 'b'),
      section(0),
      deleted(3, 'c'),
      added(  3, 'X'),
      same(   4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff(filename, expected)
    json = get_diff
    assert_equal expected, json[filename]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def get_diff
    differ.diff(test_id, @old_files, @new_files)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def deleted(number, text)
    line(text, 'deleted', number)
  end

  def same(number, text)
    line(text, 'same', number)
  end

  def added(number, text)
    line(text, 'added', number)
  end

  def line(text, type, number)
    { 'line' => text, 'type' => type, 'number' => number }
  end

  def section(index)
    { 'type' => 'section', 'index' => index }
  end

end
