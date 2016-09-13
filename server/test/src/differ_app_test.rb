#!/bin/bash ../test_wrapper.sh

# NB: if you call this file app_test.rb then SimpleCov fails to see it?!

ENV['RACK_ENV'] = 'test'
require_relative './lib_test_base'
require 'rack/test'

class DifferAppTest < LibTestBase

  include Rack::Test::Methods  # get

=begin
  def get_json(path, params = {}, headers = {})
    json_request :get, path, params, headers
  end

  def json_request(verb, path, params = {}, headers = {})
    send verb, path, params.to_json, headers.merge({ "CONTENT_TYPE" => "application/json" })
  end
=end

  def app
    App
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '200AEC',
  'empty was_files and empty now_files is benign no-op' do

    @was_files = {}
    @now_files = {}

    params = {
      :was_files => @was_files.to_json,
      :now_files => @now_files.to_json
    }

    #json_request :get, '/diff', params, headers={}
    ##get_json '/diff', params
    get '/diff', params

    json = JSON.parse(last_response.body)
    assert_equal({}, json)

    #File.open('/tmp/coverage/help.html', 'w') { |fd| fd.write(last_response.body) }
    #assert false, "body is not JSON!"

  end

end
