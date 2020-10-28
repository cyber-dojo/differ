# frozen_string_literal: true
require_relative 'differ_test_base'
require_relative 'http_adapter_stub'

class BadHttpProxyResponseTest < DifferTestBase

  def self.id58_prefix
    'f28'
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN4', %w(
  |when an http-proxy
  |returns non-JSON in its response.body
  |it raises an exception
  ) do
    stub_model_http('xxxx')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN5', %w(
  |when an http-proxy
  |returns JSON (but not a Hash) in its response.body
  |it raises an exeption
  ) do
    stub_model_http('[]')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN6', %w(
  |when an http-proxy
  |returns JSON-Hash in its response.body
  |it raises an exeption
  ) do
    stub_model_http(response='{"exception":42}')
    ready_raises_exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN7', %w(
  |when an http-proxy
  |returns JSON-Hash in its response.body
  |which does not contain the requested method's key
  |it raises an exeption
  ) do
    stub_model_http(response='{"wibble":42}')
    ready_raises_exception
  end

  private

  def stub_model_http(body)
    externals.instance_exec { @model_http = HttpAdapterStub.new(body) }
  end

  # - - - - - - - - - - - - - - - - -

  def ready_raises_exception
    assert_raises { prober.ready? }
  end

end
