require_relative 'differ_test_base'
require_relative '../src/http_json_args'

class HttpJsonArgsTest < DifferTestBase

  def self.hex_prefix
    'EE7'
  end

  # - - - - - - - - - - - - - - - - -
  # c'tor raising
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
  # c'tor not raising
  # - - - - - - - - - - - - - - - - -

  test 'c88', %w(
  ctor does not raise when body is empty string which is
  useful for kubernetes liveness/readyness probes ) do
    HttpJsonArgs.new('')
  end

  test 'c99',
  %w( ctor does not raise when string-arg is valid json ) do
    HttpJsonArgs.new('{}')
    HttpJsonArgs.new('{"answer":42}')
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with correct number of args
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

  test 'e15',
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
  # dispatch diff with one missing argument
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
  # dispatch diff with more than one missing argument
  # - - - - - - - - - - - - - - - - -

  test 'd97',
  %w( diff() missing new_files raises HttpJsonArgs::Error ) do
    assert_missing_args(:old_files, :new_files)
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with one unknown argument
  # - - - - - - - - - - - - - - - - -

  test 'c51',
  %w( sha() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/sha', {bad:21}, 'bad')
  end

  test 'c52',
  %w( alive?() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/alive', {none:"sd"}, 'none')
  end

  test 'c53',
  %w( ready?() unknown args raises HttpJsonArgs::Error ) do
    assert_unknown_args('/ready', {flag:true, a:"dfg"}, 'a', 'flag')
  end

  test 'c54',
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
    assert_equal "unknown argument: nope", error.message
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with more than one unknown argument
  # - - - - - - - - - - - - - - - - -

  test 'd51',
  %w( sha() unknown args raises HttpJsonArgs::Error ) do
    assert_unknown_args('/sha', {xxx:true, bad:21}, 'bad', 'xxx')
  end

  test 'd52',
  %w( alive?() unknown args raises HttpJsonArgs::Error ) do
    assert_unknown_args('/alive', {none:"sd", z:nil}, 'none', 'z')
  end

  test 'd53',
  %w( ready?() unknown arg raises HttpJsonArgs::Error ) do
    assert_unknown_arg('/ready', {flag:true}, 'flag')
  end

  test 'd54',
  %w( diff() unknown args raises HttpJsonArgs::Error ) do
    args = {
      id:hex_test_id,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" },
      nope:42,
      zz:false
    }
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch('/diff', differ)
    }
    assert_equal "unknown arguments: nope, zz", error.message
  end

  private

  def assert_unknown_arg(path, args, name)
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch(path, differ)
    }
    assert_equal "unknown argument: #{name}", error.message
  end

  def assert_unknown_args(path, args, *names)
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch(path, differ)
    }
    assert_equal "unknown arguments: #{names.join(', ')}", error.message
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
    assert_equal "missing argument: #{name}", error.message
  end

  def assert_missing_args(*names)
    args = {
      id:hex_test_id,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" }
    }
    names.each { |name| args.delete(name) }
    error = assert_raises(HttpJsonArgs::Error) {
      HttpJsonArgs.new(args.to_json).dispatch('/diff', differ)
    }
    assert_equal "missing arguments: #{names.join(', ')}", error.message
  end

end
