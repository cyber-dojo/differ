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
  'empty was_files and/or now_files is benign no-op' do
    diffs = Differ.new({},{}).diff
    assert_equal({}, diffs)
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2142E2',
  'file in was_files but not now_files is a deleted file' do
    was_files = {
      'hiker.h' => "a\nb\n"
    }
    now_files = {
      'diamond.h' => ''
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'a', :type=>:deleted, :number=>1 },
      { :line=>'b', :type=>:deleted, :number=>2 },
    ], diffs['hiker.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'C888D6',
  'file not in was_files but in now_files is a new file' do
    was_files = {
      'hiker.h' => ''
    }
    now_files = {
      'diamond.h' => "a\nb\n"
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :type=>:section, :index=>0 },
      { :line=>'a', :type=>:added, :number=>1 },
      { :line=>'b', :type=>:added, :number=>2 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'F1E13E',
  'file unchanged in was_files/now_files is same' do
    was_files = {
      'diamond.h' => "a\nb\n"
    }
    now_files = {
      'diamond.h' => "a\nb\n"
    }
    diffs = Differ.new(was_files, now_files).diff
    assert_equal [
      { :line=>'a', :type=>:same, :number=>1 },
      { :line=>'b', :type=>:same, :number=>2 },
    ], diffs['diamond.h']
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '6A9EDF',
  'file changed between was_files/now_files sees deleted and added lines' do
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

end
