require_relative 'differ_test_base'
require_relative 'rack_request_stub'
require_relative '../src/rack_dispatcher'

class RackDispatcherTest < DifferTestBase

  def self.hex_prefix
    '4AF'
  end

  # - - - - - - - - - - - - - - - - -

  class DifferShaStub
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
    @differ_stub = DifferShaStub.new(ArgumentError, 'wibble')
    assert_dispatch_raises('sha', {}.to_json, 500, 'wibble')
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

  def rack_call(name, args)
    rack = RackDispatcher.new(@differ_stub, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  def with_captured_stderr
    old_stderr = $stderr
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stderr.string ]
  ensure
    $stderr = old_stderr
  end

end
