# frozen_string_literal: true
require_relative 'differ_test_base'
require 'ostruct'

class BadHttpProxyResponseTest < DifferTestBase

  def self.id58_prefix
    'f28'
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN4', %w(
  |when an http-proxy
  |returns non-JSON in its response.body
  |ready absorbs the exeption and returns false
  ) do
    stub_model_http('xxxx')
    ready_returns_false
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN5', %w(
  |when an http-proxy
  |returns JSON (but not a Hash) in its response.body
  |it raises an exeption
  ) do
    stub_model_http('[]')
    ready_returns_false
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN6', %w(
  |when an http-proxy
  |returns JSON-Hash in its response.body
  |it raises an exeption
  ) do
    stub_model_http(response='{"exception":42}')
    ready_returns_false
  end

  # - - - - - - - - - - - - - - - - -

  test 'QN7', %w(
  |when an http-proxy
  |returns JSON-Hash in its response.body
  |which does not contain the requested method's key
  |it raises an exeption
  ) do
    stub_model_http(response='{"wibble":42}')
    ready_returns_false
  end

  private

  def stub_model_http(body)
    externals.instance_exec { @model_http = HttpAdapterStub.new(body) }
  end

  # - - - - - - - - - - - - - - - - -

  class HttpAdapterStub
    def initialize(body)
      @body = body
    end
    def get(_uri)
      OpenStruct.new
    end
    def start(_hostname, _port, _req)
      self
    end
    attr_reader :body
  end

  # - - - - - - - - - - - - - - - - -

  def ready_returns_false
    actual = prober.ready?
    expected = { 'ready?' => false }
    assert_equal expected, actual
  end

end
