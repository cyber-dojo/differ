require_relative 'differ_test_base'
require_relative 'http_adapter_stub'

class HttpProxyResponseTest < DifferTestBase

  test 'f28QN3', %w(
  | when an http-proxy
  | receives a JSON-Hash in its response.body
  | which has a key matching the query-string (without the args)
  | then it returns the value for that key in the JSON-Hash
  ) do
    externals.instance_exec { @saver_http = ::HttpAdapterStub.new('{"ready?":[42]}') }
    saver = ::External::Saver.new(externals)
    assert_equal [42], saver.ready?
  end

  # - - - - - - - - - - - - - - - - -

  test 'f28QN4', %w(
  | when an http-proxy
  | receives non-JSON in its response.body
  | it raises an exception
  ) do
    stub_saver_http('xxxx')
    ready_raises_exception('body is not JSON')
  end

  # - - - - - - - - - - - - - - - - -

  test 'f28QN5', %w(
  | when an http-proxy
  | receives JSON (but not a Hash) in its response.body
  | it raises an exception
  ) do
    stub_saver_http('[]')
    ready_raises_exception('body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - -

  test 'f28QN6', %w(
  | when an http-proxy
  | receives JSON-Hash with an exception key in its response.body
  | it raises an exception
  ) do
    stub_saver_http('{"exception":42}')
    ready_raises_exception('42')
  end

  # - - - - - - - - - - - - - - - - -

  test 'f28QN7', %w(
  | when an http-proxy
  | receives JSON-Hash in its response.body
  | which does not contain the requested method's key
  | it raises an exception
  ) do
    stub_saver_http('{"wibble":42}')
    ready_raises_exception('body is missing ready? key')
  end

  private

  def stub_saver_http(body)
    externals.instance_exec { @saver_http = HttpAdapterStub.new(body) }
  end

  # - - - - - - - - - - - - - - - - -

  def ready_raises_exception(expected_message)
    error = assert_raises(HttpJsonHash::ServiceError) { prober.ready }
    assert_equal expected_message, error.message
  end

end
