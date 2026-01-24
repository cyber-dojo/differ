# frozen_string_literal: true

require_relative 'client_test_base'
require_app 'http_json_hash/unpacker'
require 'ostruct'

class HttpResponseUnpackerTest < ClientTestBase

  class HttpJsonRequestBodyStubber
    def initialize(body)
      @body = body
    end

    def get(_path, _args, _params = {})
      OpenStruct.new(body: @body)
    end
  end

  test 'C20QN3', %w(
  | when an http-proxy
  | receives a JSON-Hash in its response.body
  | which has a key matching the query-string (without the args)
  | then it returns the value for that key in the JSON-Hash
  ) do
    unpacker = stub('{"diff_summary":42}')
    diff_summary = unpacker.get('diff_summary', {})
    assert_equal 42, diff_summary
  end

  # - - - - - - - - - - - - - - - - -

  test 'C20QN4', %w(
  | when an http-proxy
  | receives non-JSON in its response.body
  | it raises an exception
  ) do
    raises_exception('xxxx', 'body is not JSON')
  end

  # - - - - - - - - - - - - - - - - -

  test 'C20QN5', %w(
  | when an http-proxy
  | receives JSON (but not a Hash) in its response.body
  | it raises an exception
  ) do
    raises_exception('[]', 'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - -

  test 'C20QN6', %w(
  | when an http-proxy
  | receives JSON-Hash with an exception key in its response.body
  | it raises an exeption
  ) do
    raises_exception('{"exception":42}', 'body has embedded exception')
  end

  # - - - - - - - - - - - - - - - - -

  test 'C20QN7', %w(
  | when an http-proxy
  | receives JSON-Hash in its response.body
  | which does not contain the requested method's key
  | it raises an exeption
  ) do
    raises_exception('{"wibble":42}', 'body is missing diff_summary key')
  end

  private

  def stub(body)
    body_response = HttpJsonRequestBodyStubber.new(body)
    HttpJsonHash::Unpacker.new('differ', body_response)
  end

  def raises_exception(body_stub, expected_message)
    unpacker = stub(body_stub)
    error = assert_raises(HttpJsonHash::ServiceError) do
      unpacker.get('diff_summary', {})
    end
    json = JSON.parse(error.message)
    assert_equal expected_message, json['message']
  end

end
