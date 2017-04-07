require_relative 'client_test_base'
require_relative '../../src/git_diff'

class DifferAppTest < ClientTestBase

  def self.hex_prefix; '200'; end

  # - - - - - - - - - - - - - - - - - - - -
  # corner cases
  # - - - - - - - - - - - - - - - - - - - -

  test '347',
  '>10K query is not rejected by thin' do
    @now_files = {}
    @was_files = { 'wibble.h' => 'X'*45*1024 }
    json = get_diff
    refute_nil json['wibble.h']
  end

  test '348',
  '>10K query in nested sub-dir is not rejected by thin' do
    @now_files = {}
    @was_files = { 'gh/jk/wibble.h' => 'X'*45*1024 }
    json = get_diff
    refute_nil json['gh/jk/wibble.h']
  end

  test 'AEC',
  'empty was_files and empty now_files is benign no-op' do
    @was_files = {}
    @now_files = {}
    json = get_diff
    assert_equal({}, json)
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete
  # - - - - - - - - - - - - - - - - - - - -

  test '313',
  'deleted empty file shows as empty array' do
    @was_files = { 'hiker.h' => '' }
    @now_files = { }
    assert_diff 'hiker.h', []
  end

  test '314',
  'deleted empty file in nested sub-dir shows as empty array' do
    @was_files = { '6/7/8/hiker.h' => '' }
    @now_files = { }
    assert_diff '6/7/8/hiker.h', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FE9',
  'deleted non-empty file shows as all lines deleted' do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { }
    assert_diff 'hiker.h', [
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd')
    ]
  end

  test 'FEA',
  'deleted non-empty file in nested sub-dir shows as all lines deleted' do
    @was_files = { '4/5/6/7/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { }
    assert_diff '4/5/6/7/hiker.h', [
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B67',
  'all lines deleted but file not deleted',
  'shows as all lines deleted plus one empty line' do
    @was_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { 'hiker.h' => '' }
    assert_diff 'hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd'),
      same(1, '')
    ]
  end

  test 'B68',
  'all lines deleted but nested sub-dir file not deleted',
  'shows as all lines deleted plus one empty line' do
    @was_files = { 'r/t/y/hiker.h' => "a\nb\nc\nd\n" }
    @now_files = { 'r/t/y/hiker.h' => '' }
    assert_diff 'r/t/y/hiker.h', [
      section(0),
      deleted(1, 'a'),
      deleted(2, 'b'),
      deleted(3, 'c'),
      deleted(4, 'd'),
      same(1, '')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # add
  # - - - - - - - - - - - - - - - - - - - -

  test '95F',
  'added empty file shows as one empty file' do
    @was_files = { }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', []
  end

  test '960',
  'added empty file in nested sub-dir shows as one empty file' do
    @was_files = { }
    @now_files = { 'a/b/c/diamond.h' => '' }
    assert_diff 'a/b/c/diamond.h', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2C3',
  'added non-empty file shows as all lines added' do
    @was_files = { }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
      added(1, 'a'),
      added(2, 'b'),
      added(3, 'c'),
      added(4, 'd')
    ]
  end

  test '2C4',
  'added non-empty file in nested sub-dir shows as all lines added' do
    @was_files = { }
    @now_files = { 'q/w/e/diamond.h' => "a\nb\nc\nd" }
    assert_diff 'q/w/e/diamond.h', [
      added(1, 'a'),
      added(2, 'b'),
      added(3, 'c'),
      added(4, 'd')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -
  # no change
  # - - - - - - - - - - - - - - - - - - - -

  test '7FE',
  'unchanged empty-file shows as one empty line' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'diamond.h' => '' }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1, '') ]
  end

  test '7FF',
  'unchanged empty-file in nested sub-dir shows as one empty line' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'w/e/r/diamond.h' => '' }
    @now_files = { 'w/e/r/diamond.h' => '' }
    assert_diff 'w/e/r/diamond.h', [ same(1, '') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '365',
  'unchanged non-empty file shows as all lines same' do
    @was_files = { 'diamond.h' => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
      same(1, 'a'),
      same(2, 'b'),
      same(3, 'c'),
      same(4, 'd')
    ]
  end

  test '366',
  'unchanged non-empty file in nested sub-dir shows as all lines same' do
    @was_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    @now_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
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
    @was_files = { 'diamond.h' => 'a' }
    @now_files = { 'diamond.h' => 'b' }
    assert_diff 'diamond.h', [
      section(0),
      deleted(1, 'a'),
      added(  1, 'b')
    ]
  end

  test 'E3F',
  'changed non-empty file in nested sub-dir shows as deleted and added lines' do
    @was_files = { 't/y/u/diamond.h' => 'a1' }
    @now_files = { 't/y/u/diamond.h' => 'b2' }
    assert_diff 't/y/u/diamond.h', [
      section(0),
      deleted(1, 'a1'),
      added(  1, 'b2')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B9E',
  'changed non-empty file shows as deleted and added lines',
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
  'with each chunk in its own indexed section' do
    @was_files = {
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
    @now_files = {
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
    # does not exist in was_files
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
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
    # does not exist in was_files
    @was_files = { 'a/f/d/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'a/f/d/diamond.h' => "a\nb\nc\nd" }
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
    @was_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'diamond.h' => "a\nb\nX\nd" }
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
    @was_files = { 'a/b/c/hiker.h'   => "a\nb\nc\nd" }
    @now_files = { 'a/b/c/diamond.h' => "a\nb\nX\nd" }
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
=begin
  test '925', %w(
    renamed
  ) do
  end
=end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff(filename, expected)
    json = get_diff
    assert_equal expected, json[filename]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def get_diff
    GitDiff::git_diff(@was_files, @now_files)['diff']
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
