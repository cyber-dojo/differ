require_relative 'client_test_base'
require_app 'http_json/response_unpacker'
require_app 'http_json/service_exception'
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
    def get(_path, _args, _params={})
      OpenStruct.new(body:@body)
    end
  end

  test 'AE3',
  %w( returns response-body's entry for the path ) do
    json = unpacker({ diff:42 }.to_json).get('diff', [])
    assert_equal({'diff'=>42}, json)
  end

  # - - - - - - - - - - - - - - - - -

  class ResponseException < HttpJson::ServiceException
    def initialize(message)
      super
    end
  end

  test 'AE4',
  %w( raises when response-body is not JSON ) do
    error = assert_get_raises('xxxx')
    expected = 'http response.body is not JSON:xxxx'
    assert_equal expected, error.message
  end

  test 'AE5',
  %w( raises when response-body is not JSON Hash|Array ) do
    error = assert_get_raises('42')
    expected = 'http response.body is not JSON Hash|Array:42'
    assert_equal expected, error.message
  end

  test 'AE7',
  %w( raises when response-body is JSON Hash but has 'exception' key ) do
    error = assert_get_raises({exception:{message:'xmsg'}}.to_json)
    json = JSON.parse(error.message)
    assert_equal 'xmsg', json['message']
  end

  test 'AE6',
  %w( raises when response-body is JSON Hash, keyed:true is set, but there is no key for path ) do
    body = {x:42}.to_json
    error = assert_raises(ResponseException) {
      stub = HttpJsonResponseBodyStubber.new(body)
      unpacker = HttpJson::ResponseUnpacker.new(stub, ResponseException, keyed:true)
      unpacker.get('diff', [])
    }
    expected = "http response.body has no key for 'diff':{\"x\":42}"
    assert_equal expected, error.message
  end

  test 'AE8',
  %w( returns value when response-body is JSON Hash, keyed:true is set, and there is a key for path ) do
    body = {diff:42}.to_json
    stub = HttpJsonResponseBodyStubber.new(body)
    unpacker = HttpJson::ResponseUnpacker.new(stub, ResponseException, keyed:true)
    response = unpacker.get('diff', [])
    assert_equal({'diff'=>42}, response)
  end

  private

  def assert_get_raises(body)
    assert_raises(ResponseException) { unpacker(body).get('diff', [])}
  end

  def unpacker(body)
    stub = HttpJsonResponseBodyStubber.new(body)
    HttpJson::ResponseUnpacker.new(stub, ResponseException)
  end

end
