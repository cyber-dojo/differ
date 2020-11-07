require_relative 'differ_test_base'
require_app 'http_json_args'

class HttpJsonArgsTest < DifferTestBase

  def self.id58_prefix
    'EE7'
  end

  test 'jj8', '/diff_summary uses proper GET query args' do
    path = 'diff_summary'
    id = 'RNCzUr'
    was_index = 8
    now_index = 9
    args = { id:id, was_index:was_index, now_index:now_index }
    body = ''
    actual = dispatch("/#{path}", differ, body, args)
    expected = [
      { type: :deleted,
        old_filename: "readme.txt",
        new_filename: nil,
        line_counts: { added:0, deleted:14, same:0 }
      },
      { type: :unchanged,
        old_filename: "test_hiker.sh",
        new_filename: "test_hiker.sh",
        line_counts: { same:8, added:0, deleted:0 }
      },
      { type: :unchanged,
        old_filename: "bats_help.txt",
        new_filename: "bats_help.txt",
        line_counts: { same:3, added:0, deleted:0 }
      },
      { type: :unchanged,
        old_filename: "hiker.sh",
        new_filename: "hiker.sh",
        line_counts: { same:6, added:0, deleted:0 }
      },
      { type: :unchanged,
        old_filename: "cyber-dojo.sh",
        new_filename: "cyber-dojo.sh",
        line_counts: { same:2, added:0, deleted:0 }
      },
      { type: :unchanged,
        old_filename: "sub_dir/empty.file.rename",
        new_filename: "sub_dir/empty.file.rename",
        line_counts: { same:1, added:0, deleted:0 }
      }
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - -
  # dispatch calls with correct number of args
  # return hash with single key matching the path
  # - - - - - - - - - - - - - - - - -

  test 'e11', '/sha has no args' do
    result = dispatch('/sha', differ, '{}')
    assert_equal ['sha'], result.keys
  end

  test 'e12', '/heathy has no args' do
    result = dispatch('/healthy', differ, '{}')
    assert_equal({'healthy?' => true}, result)
  end

  test 'e13', '/alive has no args' do
    result = dispatch('/alive', differ, '{}')
    assert_equal({'alive?' => true }, result)
  end

  test 'e14', '/ready has no args' do
    result = dispatch('/ready', differ, '{}')
    assert_equal({ 'ready?' => true }, result)
  end

  test 'e18',
  %w( /diff_summary has three keyword args; id:, was_index:, now_index: ) do
    body = {
      id:'RNCzUr',
      was_index:1,
      now_index:2
    }.to_json
    result = dispatch('/diff_summary', differ, body)
    assert_equal 'Array', result.class.name
    assert_equal 5, result.size
    assert_equal 'Hash', result[0].class.name
    assert result[0].keys.include?(:new_filename)
  end

  test 'e19',
  %w( /diff_lines has three keyword args; id:, was_index:, now_index: ) do
    body = {
      id:'RNCzUr',
      was_index:1,
      now_index:2
    }.to_json
    result = dispatch('/diff_lines', differ, body)
    assert_equal 'Array', result.class.name
    assert_equal 5+3, result.size # +stdout +stderr +stdout
    assert_equal 'Hash', result[0].class.name
    assert result[0].keys.include?(:new_filename)
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

  test 'c50',
  %w( one unknown arg raises HttpJsonArgs::RequestError ) do
    assert_unknown_arg('/sha', {bad:21}, 'bad')
    assert_unknown_arg('/healthy', {bad:21}, 'bad')
    assert_unknown_arg('/alive', {none:'sd'}, 'none')
    args = { flag:true }
    none = {}
    assert_unknown_arg('/ready', args, 'flag', none)
    assert_unknown_arg('/ready', none, 'flag', args)
    params = { id:id58, was_index:'23', now_index:'24', nope:42 }
    assert_unknown_arg('/diff_summary', {}, 'nope', params)
  end

  # - - - - - - - - - - - - - - - - -

  test 'd50',
  %w( two or more unknown args raises HttpJsonArgs::RequestError ) do
    assert_unknown_args('/sha', {xxx:true, bad:21}, 'xxx', 'bad')
    assert_unknown_args('/healthy', {xxx:true, bad:21}, 'xxx', 'bad')
    assert_unknown_args('/alive', {none:'sd', z:nil}, 'none', 'z')
    assert_unknown_args('/ready', {flag:true,a:'dfg'}, 'flag', 'a')
    args = { id:id58, was_index:23, now_index:24, nope:42, zz:false }
    assert_unknown_args('/diff_summary', args, 'nope', 'zz')
  end

  private

  def dispatch(path, differ, body, params={})
    HttpJsonArgs::dispatch(path, differ, body, params)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_unknown_arg(path, args, name, params={})
    error = assert_raises(HttpJsonArgs::RequestError) {
      dispatch(path, differ, args.to_json, params)
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

=begin
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
=end

end
