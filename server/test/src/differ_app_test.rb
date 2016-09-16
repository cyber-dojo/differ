#!/bin/sh ../shebang_run.sh

# NB: if you call this file app_test.rb then SimpleCov fails to see it?!

ENV['RACK_ENV'] = 'test'
require_relative './lib_test_base'
require_relative './null_logger'
require 'rack/test'

class DifferAppTest < LibTestBase

  include Rack::Test::Methods  # get

  def app
    DifferApp
  end

  def setup
    super
    ENV['DIFFER_CLASS_LOG'] = 'NullLogger'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '200AEC',
  'empty was_files and empty now_files is benign no-op' do
    @was_files = {}
    @now_files = {}
    json = get_diff
    assert_equal({}, json)
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '88A313',
  'deleted empty file shows as empty array' do
    @was_files = { 'hiker.h' => '' }
    @now_files = { }
    assert_diff 'hiker.h', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '389069',
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

  test 'B67194',
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

  test '95F45F',
  'added empty file shows as one empty line' do
    @was_files = { }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1, '') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2C3991',
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

  test '7FE518',
  'unchanged empty-file shows as one empty line' do
    @was_files = { 'diamond.h' => '' }
    @now_files = { 'diamond.h' => '' }
    assert_diff 'diamond.h', [ same(1, '') ]
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '3651DD',
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

  test 'E50C06',
  'renamed file also shows as all lines same' do
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

  test 'E3FF9F',
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

  test 'B9F6D7',
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

  def assert_diff(filename, expected)
    get_diff
    assert_equal expected, @json[filename]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def get_diff
    params = {
      :was_files => @was_files.to_json,
      :now_files => @now_files.to_json
    }
    get '/diff', params
    @json = JSON.parse(last_response.body)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def deleted(number, text)
    line(text, 'deleted', number)
  end

  def same(number, text)
    line(text, 'same', number)
  end

  def added(number, text)
    line(text,'added', number)
  end

  def line(text, type, number)
    { 'line'=>text, 'type'=>type, 'number'=>number }
  end

  def section(index)
    { 'type'=>'section', 'index'=>index }
  end

end
