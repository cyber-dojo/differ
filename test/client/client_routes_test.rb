require_relative 'client_test_base'
require_app 'client'
require 'json'
require 'rack'

class ClientRoutesTest < ClientTestBase
  test 'Cr5qA1', %w[
    GET /ready returns 200 and the differ server's readiness
  ] do
    status, headers, body = rack_call('/ready')
    assert_equal 200, status
    assert_equal({ 'Content-Type' => 'application/json' }, headers)
    assert_equal({ 'ready' => true }, JSON.parse(body[0]))
  end

  test 'Cr5qA2', %w[
    GET of an unknown path returns 500 naming the path
    and writes the same diagnostic to stderr
  ] do
    status = headers = body = nil
    stdout, stderr = capture_io { status, headers, body = rack_call('/xyz') }
    assert_equal 500, status
    assert_equal({ 'Content-Type' => 'application/json' }, headers)
    exception = JSON.parse(body[0])['exception']
    assert_equal '/xyz', exception['path']
    assert_equal 'DifferService', exception['class']
    assert_equal 'unknown path', exception['message']
    assert_equal '', stdout
    assert_equal "#{body[0]}\n", stderr
  end

  private

  def rack_call(path)
    Client.new(differ).call(Rack::MockRequest.env_for(path))
  end
end
