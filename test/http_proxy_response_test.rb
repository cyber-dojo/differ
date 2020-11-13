# frozen_string_literal: true
require_relative 'differ_test_base'
require_relative 'http_adapter_stub'

class HttpProxyResponseTest < DifferTestBase

  def self.id58_prefix
    'f28'
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN4', %w(
  |when an http-proxy
  |receives non-JSON in its response.body
  |it raises an exception
  ) do
    stub_model_http('xxxx')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN5', %w(
  |when an http-proxy
  |receives JSON (but not a Hash) in its response.body
  |it raises an exeption
  ) do
    stub_model_http('[]')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN6', %w(
  |when an http-proxy
  |receives JSON-Hash with an 'exception' key in its response.body
  |it raises an exeption
  ) do
    stub_model_http(response='{"exception":42}')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN7', %w(
  |when an http-proxy
  |receives JSON-Hash in its response.body
  |which does not contain the requested method's key
  |it raises an exeption
  ) do
    stub_model_http(response='{"wibble":42}')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN8', %w(
  |when an http-proxy
  |receives a JSON-Hash in its response.body
  |which has a key matching the path
  |then it returns the value for that key
  ) do
    http = ::HttpAdapterStub.new('{"ready?":[42]}')
    model = ::External::Model.new(http)
    assert_equal [42], model.ready?
  end

  private

  def stub_model_http(body)
    externals.instance_exec { @model_http = HttpAdapterStub.new(body) }
  end

  # - - - - - - - - - - - - - - - - -

  def ready_raises_exception
    assert_raises { prober.ready }
  end

end
