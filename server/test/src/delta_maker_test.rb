#!/bin/sh ../test_wrapper.sh

require_relative './lib_test_base'

class DeltaMakerTest < LibTestBase

  test '82C46123',
  'make_delta does not alter arguments' do
    @was = { 'wibble.h' => 52674, 'wibble.c' => 3424234, 'fubar.h' => -234 }
    was_clone = @was.clone
    @now = { 'wibble.h' => 52674, 'wibble.c' => 46532, 'snafu.c' => -345345 }
    now_clone = @now.clone
    make_delta
    assert_equal was_clone, @was
    assert_equal now_clone, @now
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '9E4B3F',
  'make_delta({},{}) is benign no-op' do
    @was = { }
    @now = { }
    make_delta
    assert_changed []
    assert_unchanged []
    assert_deleted []
    assert_new []
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '01827F',
  'unchanged files seen as :unchanged' do
    @was = { 'wibble.h' => 3424234 }
    @now = { 'wibble.h' => 3424234 }
    make_delta
    assert_changed []
    assert_unchanged ['wibble.h']
    assert_deleted []
    assert_new []
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '89F5A4',
  'changed files seen as :changed' do
    @was = { 'wibble.h' => 52674 }
    @now = { 'wibble.h' => 3424234 }
    make_delta
    assert_changed ['wibble.h']
    assert_unchanged []
    assert_deleted []
    assert_new []
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '344B12',
  'deleted files seen as :deleted' do
    @was = { 'wibble.h' => 52674 }
    @now = {}
    make_delta
    assert_changed []
    assert_unchanged []
    assert_deleted ['wibble.h']
    assert_new []
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test 'D2894B',
  'new files seen as :new' do
    @was = {}
    @now = { 'wibble.h' => 52674 }
    make_delta
    assert_changed []
    assert_unchanged []
    assert_deleted []
    assert_new ['wibble.h']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '9E8A92',
  'example with :unchanged, :changed, :deleted, and :new' do
    @was = { 'wibble.h' => 52674, 'wibble.c' => 3424234, 'fubar.h' => -234 }
    @now = { 'wibble.h' => 52674, 'wibble.c' => 46532, 'snafu.c' => -345345 }
    make_delta
    assert_changed ['wibble.c']
    assert_unchanged ['wibble.h']
    assert_deleted ['fubar.h']
    assert_new ['snafu.c']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  private

  def make_delta
    @delta = DeltaMaker.make_delta(@was, @now)
  end

  def assert_changed(expected)
    assert_equal expected, @delta[:changed]
  end

  def assert_unchanged(expected)
    assert_equal expected, @delta[:unchanged]
  end

  def assert_deleted(expected)
    assert_equal expected, @delta[:deleted]
  end

  def assert_new(expected)
    assert_equal expected, @delta[:new]
  end

end
