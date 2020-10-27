require_relative 'differ_test_base'
require_app 'http_json_args'

class HttpJsonArgsTest < DifferTestBase

  def self.id58_prefix
    'EE7'
  end

  test 'jj9', 'SPIKE: /diff_summary2 using proper GET query args' do
    path = 'diff_summary2'
    id = 'RNCzUr'
    was_index = 8
    now_index = 9
    args = { id:id, was_index:was_index, now_index:now_index }
    body = ''
    result = dispatch("/#{path}", differ, body, args)
    assert_equal [path], result.keys
    expected = [
      { 'old_filename' => "hiker.h",
        'new_filename' => "hiker.hpp",
        'counts' => { 'added' => 0, 'deleted' => 0, 'same' => 23 },
        'lines' => []
      }
    ]
    actual = result[path]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with correct number of args
  # return hash with single key matching the path
  # - - - - - - - - - - - - - - - - -

  test 'e12', '/sha has no args' do
    result = dispatch('/sha', differ, '{}')
    assert_equal ['sha'], result.keys
  end

  test 'e13', '/alive has no args' do
    result = dispatch('/alive', differ, '{}')
    assert_equal({'alive?' => true }, result)
  end

  test 'e14', '/ready has no args' do
    result = dispatch('/ready', differ, '{}')
    assert_equal({ 'ready?' => true }, result)
  end

  test 'e15',
  %w( /diff has three keyword args; id:,old_files:,new_files: ) do
    old_files = { 'hiker.h' => "a\nb" }
    new_files = { 'hiker.h' => "a\nb\nc" }
    body = {
      id:id58,
      old_files:old_files,
      new_files:new_files
    }.to_json
    result = dispatch('/diff', differ, body)
    assert_equal ['diff'], result.keys
  end

  test 'e16',
  %w( /diff_tip_data has three keyword args; id:,old_files:,new_files: ) do
    old_files = { 'hiker.h' => "a\nb" }
    new_files = { 'hiker.h' => "a\nb\nc" }
    body = {
      id:id58,
      old_files:old_files,
      new_files:new_files
    }.to_json
    result = dispatch('/diff_tip_data', differ, body)
    assert_equal ['diff_tip_data'], result.keys
  end

  test 'e17',
  %w( /diff_summary has three keyword args; id:, was_index:, now_index: ) do
    body = {
      id:'RNCzUr',
      was_index:1,
      now_index:2
    }.to_json
    result = dispatch('/diff_summary', differ, body)
    assert_equal ['diff_summary'], result.keys
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with body that is not JSON
  # raise HttpJsonArgs::RequestError
  # - - - - - - - - - - - - - - - - -

  test 'A04',
  'dispatch raises when body string is invalid json' do
    expected = 'body is not JSON'
    info = 'abc is not a valid top-level json element'
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(nil,nil,'abc')
    }
    assert_equal expected, error.message, info
    info = 'nil is null in json'
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(nil,nil,'{"x":nil}')
    }
    assert_equal expected, error.message, info
    info = 'keys have to be strings in incoming json'
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(nil,nil,'{42:"answer"}')
    }
    assert_equal expected, error.message, info
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch diff with one missing argument
  # raise HttpJsonArgs::RequestError
  # - - - - - - - - - - - - - - - - -

  test '7B1',
  %w( diff() missing id raises HttpJsonArgs::RequestError ) do
    assert_missing_arg(:id)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B2',
  %w( diff() missing old_files raises HttpJsonArgs::RequestError ) do
    assert_missing_arg(:old_files)
  end

  # - - - - - - - - - - - - - - - - -

  test '7B3',
  %w( diff() missing new_files raises HttpJsonArgs::RequestError ) do
    assert_missing_arg(:new_files)
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch diff with more than one missing argument
  # raise HttpJsonArgs::RequestError
  # - - - - - - - - - - - - - - - - -

  test 'd97',
  %w( diff() missing old_files and new_files raises HttpJsonArgs::RequestError ) do
    assert_missing_args(:old_files, :new_files)
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with one unknown argument
  # raise HttpJsonArgs::RequestError
  # - - - - - - - - - - - - - - - - -

  test 'c51',
  %w( sha() unknown arg raises HttpJsonArgs::RequestError ) do
    assert_unknown_arg('/sha', {bad:21}, 'bad')
  end

  test 'c52',
  %w( alive?() unknown arg raises HttpJsonArgs::RequestError ) do
    assert_unknown_arg('/alive', {none:'sd'}, 'none')
  end

  test 'c53',
  %w( ready?() unknown arg raises HttpJsonArgs::RequestError ) do
    assert_unknown_arg('/ready', {flag:true}, 'flag')
  end

  test 'c54',
  %w( diff() unknown arg raises HttpJsonArgs::RequestError ) do
    args = {
      id:id58,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" },
      nope:42
    }
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch('/diff', differ, args.to_json)
    }
    assert_equal 'unknown argument: :nope', error.message
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with more than one unknown argument
  # raise HttpJsonArgs::RequestError
  # - - - - - - - - - - - - - - - - -

  test 'd51',
  %w( sha() unknown args raises HttpJsonArgs::RequestError ) do
    assert_unknown_args('/sha', {xxx:true, bad:21}, 'xxx', 'bad')
  end

  test 'd52',
  %w( alive?() unknown args raises HttpJsonArgs::RequestError ) do
    assert_unknown_args('/alive', {none:'sd', z:nil}, 'none', 'z')
  end

  test 'd53',
  %w( ready?() unknown arg raises HttpJsonArgs::RequestError ) do
    assert_unknown_args('/ready', {flag:true,a:'dfg'}, 'flag', 'a')
  end

  test 'd54',
  %w( diff() unknown args raises HttpJsonArgs::RequestError ) do
    args = {
      id:id58,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" },
      nope:42,
      zz:false
    }
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch('/diff', differ, args.to_json)
    }
    assert_equal 'unknown arguments: :nope, :zz', error.message
  end

  private

  def dispatch(path, differ, body, params={})
    HttpJsonArgs::dispatch(path, differ, body, params)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_unknown_arg(path, args, name)
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(path, differ, args.to_json)
    }
    assert_equal "unknown argument: :#{name}", error.message
  end

  # - - - - - - - - - - - - - - - - -

  def assert_unknown_args(path, args, *names)
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(path, differ, args.to_json)
    }
    names.map!{ |name| ':'+name }
    assert_equal "unknown arguments: #{names.join(', ')}", error.message
  end

  # - - - - - - - - - - - - - - - - -

  def assert_missing_arg(name)
    args = {
      id:id58,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" }
    }
    args.delete(name)
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch('/diff', differ, args.to_json)
    }
    assert_equal "missing argument: :#{name}", error.message
  end

  # - - - - - - - - - - - - - - - - -

  def assert_missing_args(*names)
    args = {
      id:id58,
      old_files:{ 'hiker.h' => "a\nb" },
      new_files:{ 'hiker.h' => "a\nb\nc" }
    }
    names.each { |name| args.delete(name) }
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch('/diff', differ, args.to_json)
    }
    names.map!{ |name| ":#{name}" }
    assert_equal "missing arguments: #{names.join(', ')}", error.message
  end

end
