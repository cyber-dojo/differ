require_relative 'differ_test_base'
require_relative '../src/http_json_args'

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
    # keys have to be strings in incoming json
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
    result = HttpJsonArgs.new('{}').dispatch('/sha', differ)
    assert_equal ['sha'], result.keys
  end

  test 'e13', 'alive has no args' do
    result = HttpJsonArgs.new('{}').dispatch('/alive', differ)
    assert_equal({'alive?' => true }, result)
  end

  test 'e14', 'ready has no args' do
    result = HttpJsonArgs.new('{}').dispatch('/ready', differ)
    assert_equal({ 'ready?' => true }, result)
  end

  # - - - - - - - - - - - - - - - - -

  test '1BC',
  %w( diff has three keyword args; id:,old_files:,new_files: ) do
    old_files = { 'hiker.h' => "a\nb" }
    new_files = { 'hiker.h' => "a\nb\nc" }
    body = {
      id:hex_test_id,
      old_files:old_files,
      new_files:new_files
    }.to_json
    result = HttpJsonArgs.new(body).dispatch('/diff', differ)
    assert_equal ['diff'], result.keys
  end

  # - - - - - - - - - - - - - - - - -
  # missing arguments
  # - - - - - - - - - - - - - - - - -

  test '7B1',
  %w( diff() missing id raises HttpJsonArgs::Error ) do
    assert_missing_arg(:id)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B2',
  %w( diff() missing old_files raises HttpJsonArgs::Error ) do
    assert_missing_arg(:old_files)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B3',
  %w( diff() missing new_files raises HttpJsonArgs::Error ) do
    assert_missing_arg(:new_files)
  end

  # - - - - - - - - - - - - - - - - -
  # unknown arguments
  # - - - - - - - - - - - - - - - - -

  test 'c52',
  %w( diff() unknown arg raises HttpJsonArgs::Error ) do
    args = {
      id:hex_test_id,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" },
      nope:42
    }
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch('/diff', differ)
    }
    assert_equal "unknown keyword: nope", error.message
  end

  # - - - - - - - - - - - - - - - - -

  test 'c53',
  %w( sha() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/sha', {bad:21})
  end

  # - - - - - - - - - - - - - - - - -

  test 'c54',
  %w( alive?() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/alive', {none:"sd"})
  end

  # - - - - - - - - - - - - - - - - -

  test 'c55',
  %w( ready?() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/ready', {flag:true})
  end

  private

  def assert_unknown_arg(path, args)
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch(path, differ)
    }
    assert_equal 'unknown arguments', error.message
  end

  # - - - - - - - - - - - - - - - - -

  def assert_missing_arg(name)
    args = {
      id:hex_test_id,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" }
    }
    args.delete(name)
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch('/diff', differ)
    }
    assert_equal "missing keyword: #{name}", error.message
  end

end
