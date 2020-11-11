# frozen_string_literal: true
require_relative 'differ_test_base'
require_relative 'http_adapter_stub'

class HttpProxyResponseTest < DifferTestBase

  def self.id58_prefix
    'f28'
  end

  test 'QN7', %w(
  |when an http-proxy response.body's JSON-Hash does not have a key matching the path
  |then it returns the JSON-Hash
  ) do
    http = ::HttpAdapterStub.new('{"wibble":42}')
    model = ::External::Model.new(http)
    assert_equal({"wibble"=>42}, model.ready?)
  end

  test 'QN4', %w(
  |when an http-proxy response.body is not JSON
  |then an exception is raised
  ) do
    stub_model_http('xxxx')
    ready_raises_exception
  end

  test 'QN6', %w(
  |when an http-proxy response.body's JSON-Hash has a key 'exception'
  |then it raises the exeption
  ) do
    stub_model_http(response='{"exception":42}')
    ready_raises_exception
  end

  private

  def stub_model_http(body)
    externals.instance_exec { @model_http = ::HttpAdapterStub.new(body) }
  end

  def ready_raises_exception
    assert_raises { prober.ready? }
  end

end
