
# NB: if you call this file app_test.rb then SimpleCov fails to see it?!

ENV['RACK_ENV'] = 'test'
require_relative './lib_test_base'
require_relative './null_logger'

class DifferTest < LibTestBase

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
  'empty was_files and empty now_files is benign no-op' do
    @was_files = {}
    @now_files = {}
    assert_equal({}, diff)
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '51A',
  'deleted empty file shows as empty array' do
    @was_files = { 'hiker.h' => '' }
    @now_files = { }
    assert_diff 'hiker.h', []
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete
  # - - - - - - - - - - - - - - - - - - - -

  test '369',
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

  # - - - - - - - - - - - - - - - - - - - -

  test '194',
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

  # - - - - - - - - - - - - - - - - - - - -
  # add
  # - - - - - - - - - - - - - - - - - - - -

  test '45F',
  'added empty file shows as one empty line' do
    @was_files = { }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1, '') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '991',
  'added non-empty file shows as all lines added' do
    @was_files = { }
    @now_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff 'diamond.h', [
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

  test '518',
  'unchanged empty-file shows as one empty line' do
    # same as adding an empty file except in this case
    # the filename exists in was_files
    @was_files = { 'diamond.h' => '' }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1, '') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '1DD',
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

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test 'F9F',
  'changed non-empty file shows as deleted and added lines' do
    @was_files = { 'diamond.h' => 'a' }
    @now_files = { 'diamond.h' => 'b' }
    assert_diff 'diamond.h', [
      section(0),
      deleted(1, 'a'),
      added(  1, 'b')
    ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '6D7',
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

  # - - - - - - - - - - - - - - - - - - - -
  # rename
  # - - - - - - - - - - - - - - - - - - - -

  test 'C06',
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

  # - - - - - - - - - - - - - - - - - - - -

  test '6BE',
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

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff(filename, expected)
    assert_equal expected, diff[filename]
  end

  def diff
    Differ.new(@was_files, @now_files).diff
  end

  # - - - - - - - - - - - - - - - - - - - -

  def deleted(number, text)
    line(text, :deleted, number)
  end

  def same(number, text)
    line(text, :same, number)
  end

  def added(number, text)
    line(text, :added, number)
  end

  def line(text, type, number)
    { :line => text, :type => type, :number => number }
  end

  def section(index)
    { :type => :section, :index => index }
  end

end
