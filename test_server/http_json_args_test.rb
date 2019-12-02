require_relative 'differ_test_base'
require_relative '../src/http_json_args'
require_relative '../src/http_json/request_error'

class HttpJsonArgsTest < DifferTestBase

  def self.hex_prefix
    'EE7'
  end

  # - - - - - - - - - - - - - - - - -

  test 'A04',
  'ctor raises when its string-arg is invalid json' do
    expected = 'body is not JSON'
    # abc is not a valid top-level json element
    error = assert_raises { HttpJsonArgs.new('abc') }
    assert_equal expected, error.message
    # nil is null in json
    error = assert_raises { HttpJsonArgs.new('{"x":nil}') }
    assert_equal expected, error.message
    # keys have to be strings in json
    error = assert_raises { HttpJsonArgs.new('{42:"answer"}') }
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - -

  test 'c89', %w(
  ctor does not raise when body is empty string which is
  useful for kubernetes liveness/readyness probes ) do
    HttpJsonArgs.new('')
  end

  test '691',
  %w( ctor does not raise when string-arg is valid json ) do
    HttpJsonArgs.new('{}')
    HttpJsonArgs.new('{"answer":42}')
  end

  # - - - - - - - - - - - - - - - - -

  test 'e12', 'sha has no args' do
    name,args = HttpJsonArgs.new('{}').get('/sha')
    assert_equal name, 'sha'
    assert_equal [], args
  end

  test 'e13', 'alive has no args' do
    name,args = HttpJsonArgs.new('{}').get('/alive')
    assert_equal name, 'alive?'
    assert_equal [], args
  end

  test 'e14', 'ready has no args' do
    name,args = HttpJsonArgs.new('{}').get('/ready')
    assert_equal name, 'ready?'
    assert_equal [], args
  end

  # - - - - - - - - - - - - - - - - -

  test '1BC',
  %w( diff[id,old_files,new_files] ) do
    old_files = { 'hiker.h' => "a\nb" }
    new_files = { 'hiker.h' => "a\nb\nc" }
    body = {
      id:hex_test_id,
      old_files:old_files,
      new_files:new_files
    }.to_json
    name,args = HttpJsonArgs.new(body).get('/diff')
    assert_equal 'diff', name
    assert_equal 'EE71BC',  args[0]
    assert_equal old_files, args[1]
    assert_equal new_files, args[2]
  end

  # - - - - - - - - - - - - - - - - -
  # missing arguments
  # - - - - - - - - - - - - - - - - -

  test '7B1',
  %w( missing id raises HttpJson::RequestError ) do
    assert_missing(:id)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B2',
  %w( missing old_files raises HttpJson::RequestError ) do
    assert_missing(:old_files)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B3',
  %w( missing new_files raises HttpJson::RequestError ) do
    assert_missing(:new_files)
  end

  private

  def assert_missing(name)
    args = {
      id:hex_test_id,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" }
    }
    args.delete(name)
    error = assert_raises(HttpJson::RequestError) {
      HttpJsonArgs.new(args.to_json).get('/diff')
    }
    assert_equal "#{name} is missing", error.message
  end

end
