require_relative 'differ_test_base'
require_relative 'rack_request_stub'
require_relative '../src/rack_dispatcher'

class RackDispatcherTest < DifferTestBase

  def self.hex_prefix
    '4AF'
  end

  # - - - - - - - - - - - - - - - - -

  class DifferShaRaiser
    def initialize(*args)
      @klass = args[0]
      @message = args[1]
    end
    def sha
      raise @klass, @message
    end
  end

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    @differ = DifferShaRaiser.new(ArgumentError, 'wibble')
    assert_dispatch_raises('sha', {}.to_json, 500, 'wibble')
  end

  test 'F1B',
  'dispatch returns 500 status when implementation has syntax error' do
    @differ = DifferShaRaiser.new(SyntaxError, 'fubar')
    assert_dispatch_raises('sha', {}.to_json, 500, 'fubar')
  end

  test 'E2A',
  'dispatch raises 400 when method name is unknown' do
    @differ = Object.new
    assert_dispatch_raises('xyz', {}.to_json, 400, 'unknown path')
  end

  test 'E2B',
  'dispatch returns 400 status when JSON is malformed' do
    @differ = Object.new
    assert_dispatch_raises('xyz', [].to_json, 400, 'body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class DifferStub
    def sha
      'hello from sha stub'
    end
    def ready?
      'hello from ready? stub'
    end
  end

  test 'E40',
  'dispatch to ready? is 200' do
    @differ = DifferStub.new
    assert_dispatch('ready', {}.to_json, 'hello from ready? stub')
  end

  test 'E41',
  'dispatch to sha is 200' do
    @differ = DifferStub.new
    assert_dispatch('sha', {}.to_json, 'hello from sha stub')
  end

  private

  def assert_dispatch_raises(name, args, status, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    assert_equal status, response[0], "message:#{message},stderr:#{stderr}"
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    my_assert_exception(response[2][0], name, args, message)
    my_assert_exception(stderr,         name, args, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def my_assert_exception(s, name, body, message)
    json = JSON.parse!(s)
    exception = json['exception']
    refute_nil exception
    assert_equal '/'+name, exception['path'], "path:#{__LINE__}"
    assert_equal body, exception['body'], "body:#{__LINE__}"
    assert_equal 'DifferService', exception['class'], "exception['class']:#{__LINE__}"
    assert_equal message, exception['message'], "exception['message']:#{__LINE__}"
    assert_equal 'Array', exception['backtrace'].class.name, "exception['backtrace'].class.name:#{__LINE__}"
    assert_equal 'String', exception['backtrace'][0].class.name, "exception['backtrace'][0].class.name:#{__LINE__}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    if query?(name)
      qname = name + '?'
    else
      qname = name
    end
    assert_rack_call(name, args, { qname => stubbed })
  end

  def query?(name)
    ['ready'].include?(name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_rack_call(name, args, expected)
    response = rack_call(name, args)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal [to_json(expected)], response[2], args
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_json(body)
    JSON.generate(body)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def rack_call(name, args)
    rack = RackDispatcher.new(@differ, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stderr
    old_stderr = $stderr
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stderr.string ]
  ensure
    $stderr = old_stderr
  end

end
