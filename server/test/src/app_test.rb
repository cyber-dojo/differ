#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'
require 'rack/test'

class AppTest < LibTestBase

  include Rack::Test::Methods

  def app
    App
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '200AEC',
  'empty was_files and empty now_files is benign no-op' do

    params = {
      :format    => :json,
      :was_files => {},
      :now_files => {}
    }

    get '/', params

    assert_raises(JSON::ParserError) { JSON.parse(last_response.body) }
    assert false, "body is not JSON!"

  end

end
