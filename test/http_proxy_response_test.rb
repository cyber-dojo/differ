# frozen_string_literal: true
require_relative 'differ_test_base'
require_relative 'http_adapter_stub'

class HttpProxyResponseTest < DifferTestBase

  def self.id58_prefix
    'f28'
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN3', %w(
  |when an http-proxy
  |receives a JSON-Hash in its response.body
  |which has a key matching the query-string (without the args)
  |then it returns the value for that key in the JSON-Hash
  ) do
    externals.instance_exec { @model_http = ::HttpAdapterStub.new('{"ready?":[42]}') }
    model = ::External::Model.new(externals)
    assert_equal [42], model.ready?
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN4', %w(
  |when an http-proxy
  |receives non-JSON in its response.body
  |it raises an exception
  ) do
    stub_model_http('xxxx')
    ready_raises_exception('body is not JSON')
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN5', %w(
  |when an http-proxy
  |receives JSON (but not a Hash) in its response.body
  |it raises an exception
  ) do
    stub_model_http('[]')
    ready_raises_exception('body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN6', %w(
  |when an http-proxy
  |receives JSON-Hash with an 'exception' key in its response.body
  |it raises an exception
  ) do
    stub_model_http(response='{"exception":42}')
    ready_raises_exception('body has embedded exception')
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN7', %w(
  |when an http-proxy
  |receives JSON-Hash in its response.body
  |which does not contain the requested method's key
  |it raises an exception
  ) do
    stub_model_http(response='{"wibble":42}')
    ready_raises_exception('body is missing ready? key')
  end

  private

  def stub_model_http(body)
    externals.instance_exec { @model_http = HttpAdapterStub.new(body) }
  end

  # - - - - - - - - - - - - - - - - -

  def ready_raises_exception(expected_message)
    error = assert_raises(HttpJsonHash::ServiceError) { prober.ready }
    assert_equal expected_message, error.message
  end

end
