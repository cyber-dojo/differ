require_relative 'client_test_base'
require_src 'http_json/response_unpacker'
require_src 'http_json/service_exception'
require 'ostruct'

class HttpResponseUnpackerTest < ClientTestBase

  def self.id58_prefix
    'C20'
  end

  # - - - - - - - - - - - - - - - - -

  class HttpJsonResponseBodyStubber
    def initialize(body)
      @body = body
    end
    def get(_path, _args)
      OpenStruct.new(body:@body)
    end
  end

  test 'AE3',
  %w( returns response-body's entry for the path ) do
    json = unpacker({ diff:42 }.to_json).get('diff', [])
    assert_equal 42, json
  end

  # - - - - - - - - - - - - - - - - -

  class ResponseException < HttpJson::ServiceException
    def initialize(message)
      super
    end
  end

  test 'AE4',
  %w( raises if response-body is not JSON ) do
    error = assert_get_raises('xxxx')
    expected = 'http response.body is not JSON:xxxx'
    assert_equal expected, error.message
  end

  test 'AE5',
  %w( raises if response-body is not JSON Hash ) do
    error = assert_get_raises([].to_json)
    expected = 'http response.body is not JSON Hash:[]'
    assert_equal expected, error.message
  end

  test 'AE6',
  %w( raises if response-body is JSON Hash but has no key for path ) do
    error = assert_get_raises({x:42}.to_json)
    expected = "http response.body has no key for 'diff':{\"x\":42}"
    assert_equal expected, error.message
  end

  test 'AE7',
  %w( raises if response-body is JSON Hash but has 'exception' key ) do
    error = assert_get_raises({exception:{message:'xmsg'}}.to_json)
    json = JSON.parse(error.message)
    assert_equal 'xmsg', json['message']
  end

  private

  def unpacker(body)
    stub = HttpJsonResponseBodyStubber.new(body)
    HttpJson::ResponseUnpacker.new(stub, ResponseException)
  end

  def assert_get_raises(body)
    assert_raises(ResponseException) { unpacker(body).get('diff', [])}
  end

end
