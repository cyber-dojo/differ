#!/bin/bash ../test_wrapper.sh

# NB: if you call this file app_test.rb then SimpleCov fails to see it?!

ENV['RACK_ENV'] = 'test'
require_relative './lib_test_base'
require 'rack/test'

class DifferAppTest < LibTestBase

  include Rack::Test::Methods  # get

  def app
    App
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

  def get_diff
    params = {
      :was_files => @was_files.to_json,
      :now_files => @now_files.to_json
    }
    get '/diff', params
    JSON.parse(last_response.body)
  end

end
