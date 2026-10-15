require_relative 'differ_test_base'
require_app 'app'
require 'json'
require 'rack/test'

class AppRoutesTest < DifferTestBase
  include Rack::Test::Methods

  test 'Rt8wA1', %w(
  | GET /alive returns 200 and alive under both its plain and ? names
  ) do
    assert_equal({ 'alive' => true, 'alive?' => true }, get_json_200('/alive', ''))
  end

  test 'Rt8wA2', %w(
  | GET /ready returns 200 and ready under both its plain and ? names
  ) do
    assert_equal({ 'ready' => true, 'ready?' => true }, get_json_200('/ready', ''))
  end

  test 'Rt8wA3', %w(
  | GET /sha returns 200 and the sha of the image's git commit
  ) do
    assert_equal({ 'sha' => prober.sha }, get_json_200('/sha', ''))
  end

  test 'Rt8wA4', %w(
  | GET /diff_lines with a JSON body returns 200 and what Differ#diff_lines returns
  ) do
    args = { was_files: { 'hiker.rb' => "a\n" }, now_files: { 'hiker.rb' => "a\nb\n" } }
    expected = JSON.parse({ 'diff_lines' => differ.diff_lines(**args) }.to_json)
    assert_equal expected, get_json_200('/diff_lines', args.to_json)
  end

  test 'Rt8wB1', %w(
  | GET with a body that is not JSON returns 500 and the error as a JSON diagnostic.
  | The same diagnostic is written to stdout.
  ) do
    assert_json_500('/sha', 'not-json', 'body is not JSON')
  end

  test 'Rt8wB2', %w(
  | GET with a JSON body that is not a Hash returns 500 and the error as a JSON diagnostic.
  | The same diagnostic is written to stdout.
  ) do
    assert_json_500('/sha', '[]', 'body is not JSON Hash')
  end

  private

  def app
    # The server's own Sinatra app, driven in-process by rack-test.
    App.new(externals)
  end

  def get_json(path, body)
    # GET path with body as its input, asking for JSON.
    get(path, {}, { input: body, 'HTTP_ACCEPT' => 'application/json' })
  end

  def get_json_200(path, body)
    # GET path, assert a 200 JSON response, and return its parsed body.
    get_json(path, body)
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.headers['Content-Type']
    JSON.parse(last_response.body)
  end

  def assert_json_500(path, body, message)
    # GET path, assert a 500 JSON diagnostic naming message, also written to stdout.
    stdout, stderr = capture_io { get_json(path, body) }
    assert_equal 500, last_response.status
    assert_equal 'application/json', last_response.headers['Content-Type']
    exception = JSON.parse(last_response.body)['exception']
    assert_equal message, exception['message']
    assert_equal path, exception['request']['path']
    assert_equal body, exception['request']['body']
    assert_equal "#{last_response.body}\n", stdout
    assert_equal '', stderr
  end
end
