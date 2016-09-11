#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'
require_relative './null_logger'

class DifferTest < LibTestBase

  def setup
    super
    ENV['DIFFER_CLASS_LOG'] = 'NullLogger'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '9552DC',
  'empty was_files and now_files is benign no-op' do
    diffs = Differ.new({},{}).diff
    assert_equal({}, diffs)
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '1870E3',
  'deleted empty file shows empty array' do
    was_files = { 'hiker.h' => '' }
    now_files = {}
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [], diffs['hiker.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2142E2',
  'deleted non-empty file shows as all lines deleted' do
    was_files = {
      'hiker.h' => "a\nb\nc\nd\n"
    }
    now_files = {
      'diamond.h' => ''
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'a', :type=>:deleted, :number=>1 },
      { :line=>'b', :type=>:deleted, :number=>2 },
      { :line=>'c', :type=>:deleted, :number=>3 },
      { :line=>'d', :type=>:deleted, :number=>4 },
    ], diffs['hiker.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '01CECA',
  'added empty file shows as one empty line' do
    was_files = {
      'hiker.h' => "a\nb\nc\nd"
    }
    now_files = {
      'diamond.h' => ''
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'', :type=>:same, :number=>1 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'C888D6',
  'added non-empty file shows as all lines added' do
    was_files = {
      'hiker.h' => ''
    }
    now_files = {
      'diamond.h' => "a\nb\nc\nd"
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :type=>:section, :index=>0 },
      { :line=>'a', :type=>:added, :number=>1 },
      { :line=>'b', :type=>:added, :number=>2 },
      { :line=>'c', :type=>:added, :number=>3 },
      { :line=>'d', :type=>:added, :number=>4 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B3ABA1',
  'unchanged empty-file shows as one empty line' do
    was_files = {
      'diamond.h' => ''
    }
    now_files = {
      'diamond.h' => ''
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'', :type=>:same, :number=>1 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'F1E13E',
  'unchanged non-empty file shows as all lines same' do
    was_files = {
      'diamond.h' => "a\nb\nc\nd"
    }
    now_files = {
      'diamond.h' => "a\nb\nc\nd"
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'a', :type=>:same, :number=>1 },
      { :line=>'b', :type=>:same, :number=>2 },
      { :line=>'c', :type=>:same, :number=>3 },
      { :line=>'d', :type=>:same, :number=>4 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '6A9EDF',
  'changed non-empty file shows as deleted and added lines' do
    was_files = {
      'diamond.h' => 'a'
    }
    now_files = {
      'diamond.h' => 'b'
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :type=>:section, :index=>0 },
      { :line=>'a', :type=>:deleted, :number=>1 },
      { :line=>'b', :type=>:added,   :number=>1 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '9E7B9E',
  'changed non-empty file shows as deleted and added lines ' +
  'with each chunk in its own indexed section' do
    was_files = {
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
    now_files = {
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
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'#ifndef DIAMOND',     :type=>:same,    :number=>1 },
      { :line=>'#define DIAMOND',     :type=>:same,    :number=>2 },
      { :line=>'',                    :type=>:same,    :number=>3 },

      { :type=>:section, :index=>0 },
      { :line=>'#include <strin>',    :type=>:deleted, :number=>4 },
      { :line=>'#include <string>',   :type=>:added,   :number=>4 },

      { :line=>'',                    :type=>:same,    :number=>5 },

      { :type=>:section, :index=>1 },
      { :line=>'void diamond(char)',  :type=>:deleted, :number=>6 },
      { :line=>'void diamond(char);', :type=>:added,   :number=>6 },

      { :line=>'',                    :type=>:same,    :number=>7 },
      { :line=>'#endif',              :type=>:same,    :number=>8 },
    ], diffs['diamond.h']
  end

end
