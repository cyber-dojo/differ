require_relative 'differ_test_base'
require_relative '../src/http_json_args'

class HttpJsonArgsTest < DifferTestBase

  def self.hex_prefix
    'EE7'
  end

  # - - - - - - - - - - - - - - - - -

  test 'A04',
  'ctor raises when its string-arg is not valid json' do
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

  test '691',
  %w( ctor does not raise when string-arg is valid json ) do
    HttpJsonArgs.new({}.to_json)
    HttpJsonArgs.new({ answer:42 }.to_json)
  end

  # - - - - - - - - - - - - - - - - -

  test '1BB',
  %w( diff[was_files,now_files] old arg-names during arg-rename switch-over ) do
    was_files = { "name" => "a\nb" }
    now_files = {}
    body = { was_files:was_files,now_files:now_files }.to_json
    args = HttpJsonArgs.new(body).get('/diff')
    assert_equal 'diff', args[0]
    assert_equal was_files, args[1][0]
    assert_equal now_files, args[1][1]
  end

  # - - - - - - - - - - - - - - - - -

  test '1BC',
  %w( diff2[old_files,new_files] ) do
    old_files = { "name" => "a\nb" }
    new_files = {}
    body = { old_files:old_files,new_files:new_files }.to_json
    args = HttpJsonArgs.new(body).get('/diff')
    assert_equal 'diff', args[0]
    assert_equal old_files, args[1][0]
    assert_equal new_files, args[1][1]
  end

end
