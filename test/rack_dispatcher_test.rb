require_relative 'differ_test_base'
require_relative 'rack_request_stub'
require_relative 'http_adapter_stub'
require_app 'rack_dispatcher'

class RackDispatcherTest < DifferTestBase

  def self.id58_prefix
    '4AF'
  end

  test 'ss6', %w[
  |healthy? (used in Dockerfile HEALTHCHECK)
  |logs exception to /tmp/healthy.fail.log
  |and not to stdout/stderr
  ] do
    externals.instance_exec { @model_http = HttpAdapterStub.new(not_json='xxxx') }
    log_filename = '/tmp/healthy.fail.log'
    IO.write(log_filename, '')
    response,stdout,stderr = with_captured_stdout_stderr { rack_call('healthy', '') }
    logged = IO.read(log_filename)
    assert_equal '', stdout
    assert_equal '', stderr
    assert_equal 500, response[0], "response:#{response}"
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_json_exception(response[2][0], 'healthy', '', 'body is not JSON')
    assert_json_exception(logged        , 'healthy', '', 'body is not JSON')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '129', %w(
  allow empty body instead of {} which is
  useful for kubernetes live/ready probes ) do
    response = rack_call('ready', '')
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal({"ready?" => true}, JSON.parse(response[2][0]))
  end

  test '130', 'sha 200' do
    args = {}
    assert_200('sha', args) do |response|
      assert_equal ENV['SHA'], response['sha']
    end
  end

  test '131', 'healthy 200' do
    args = {}
    assert_200('healthy', args) do |response|
      assert_equal true, response['healthy?']
    end
  end

  test '132', 'alive 200' do
    args = {}
    assert_200('alive', args) do |response|
      assert_equal true, response['alive?']
    end
  end

  test '133', 'ready 200' do
    args = {}
    assert_200('ready', args) do |response|
      assert_equal true, response['ready?']
    end
  end

  test '134', 'diff 200' do
    args = { id:id58, old_files:{}, new_files:{} }
    assert_200('diff', args) do |response|
      assert_equal({}, response['diff'])
    end
  end

  test '137', %w(
  diff_summary2 200 is in more general format
  to allow more information to be added, specifically
  - old and new filenames to detect file new|delete|rename
  - unchanged line-count
  ) do
    args = { id:'RNCzUr', was_index:4, now_index:5 }
    assert_200('diff_summary2', args) do |response|
      expected = [
        { "old_filename" => nil,
          "new_filename" => "empty.file",
          "line_counts" => { "added"=>0, "deleted"=>0, "same"=>0 }
        },
        {
          "old_filename" => "hiker.sh",
          "new_filename" => "hiker.sh",
          "line_counts"  => { "added"=>1, "deleted"=>1, "same"=>5 }
        }
      ]
      assert_equal expected, response['diff_summary2']
    end

    args = { id:'RNCzUr', was_index:1, now_index:2 }
    assert_200('diff_summary2', args) do |response|
      expected = [
        { "old_filename" => "hiker.sh",
          "new_filename" => "hiker.sh",
          "line_counts" => { "added"=>1, "deleted"=>1, "same"=>5 }
        },
        { "old_filename" => "readme.txt",
          "new_filename" => "readme.txt",
          "line_counts" => { "added"=>6, "deleted"=>3, "same"=>8 }
        },
      ]
      assert_equal expected, response['diff_summary2']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 400
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E20',
  'dispatch returns 400 status when body is not JSON' do
    assert_dispatch_error('sha', '123', 400, 'body is not JSON Hash')
  end

  test 'E21',
  'dispatch returns 400 status when body is not JSON Hash' do
    assert_dispatch_error('sha', [].to_json, 400, 'body is not JSON Hash')
  end

  test 'E22',
  'dispatch returns 400 when method name is unknown' do
    assert_dispatch_error('xyz', {}.to_json, 400, 'unknown path')
  end

  test 'E23',
  'dispatch returns 400 when one arg is unknown' do
    assert_dispatch_error('sha',   {x:42}.to_json, 400, 'unknown argument: :x')
    assert_dispatch_error('diff', {a:0,id:1,old_files:2,new_files:3}.to_json, 400,
      'unknown argument: :a')
  end

  test 'E24',
  'dispatch returns 400 when two or more args are unknown' do
    assert_dispatch_error('sha',   {x:4,y:2}.to_json, 400, 'unknown arguments: :x, :y')
    assert_dispatch_error('diff', {b:0,id:1,old_files:2,new_files:3,a:4}.to_json, 400,
      'unknown arguments: :b, :a')
  end

  test 'E25',
  'diff returns 400 when one arg is missing' do
    args = { old_files:{}, new_files:{} }
    assert_dispatch_error('diff', args.to_json, 400, 'missing argument: :id')
  end

  test 'E26',
  'diff returns 400 when two or more args are missing' do
    args = { new_files:{} }
    assert_dispatch_error('diff', args.to_json, 400, 'missing arguments: :id, :old_files')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

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
    assert_dispatch_error('sha', {}.to_json, 500, 'wibble')
  end

  test 'F1B',
  'dispatch returns 500 status when implementation has syntax error' do
    @differ = DifferShaRaiser.new(SyntaxError, 'fubar')
    assert_dispatch_error('sha', {}.to_json, 500, 'fubar')
  end

  private

  def assert_200(name, args)
    response = rack_call(name, args.to_json)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    yield JSON.parse(response[2][0])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_error(name, args, status, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    assert_equal status, response[0], "message:#{message},stderr:#{stderr}"
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_json_exception(response[2][0], name, args, message)
    assert_json_exception(stderr,         name, args, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_json_exception(s, name, body, message)
    json = JSON.parse!(s)
    exception = json['exception']
    refute_nil exception
    diagnostic = "path:#{__LINE__}"
    assert_equal '/'+name, exception['path'], diagnostic
    diagnostic = "body:#{__LINE__}"
    assert_equal body, exception['body'], diagnostic
    diagnostic = "exception['class']:#{__LINE__}"
    assert_equal 'DifferService', exception['class'], diagnostic
    diagnostic = "exception['message']:#{__LINE__}"
    assert_equal message, exception['message'], diagnostic
    diagnostic = "exception['backtrace'].class.name:#{__LINE__}"
    assert_equal 'Array', exception['backtrace'].class.name, diagnostic
    diagnostic = "exception['backtrace'][0].class.name:#{__LINE__}"
    assert_equal 'String', exception['backtrace'][0].class.name, diagnostic
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def rack_call(name, args)
    @differ ||= Differ.new(externals)
    rack = RackDispatcher.new(@differ, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stdout_stderr
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new('', 'w')
    $stderr = StringIO.new('', 'w')
    response = yield
    return [ response, $stdout.string, $stderr.string ]
  ensure
    $stderr = old_stderr
    $stdout = old_stdout
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
