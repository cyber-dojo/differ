require_relative 'http_json_args'
require 'json'
require 'rack'

class Client
  def initialize(differ)
    @differ = differ
  end

  def call(env)
    request = Rack::Request.new(env)
    path = request.path_info
    name, args = HttpJsonArgs.new.get(path)
    result = @differ.public_send(name, *args)
    html_json_pass(200, { name => result })
  rescue Exception => e
    html_json_fail(500, path, e)
  end

  def html_json_pass(status, result)
    json = JSON.generate(result)
    html_json(status, json)
  end

  def html_json_fail(status, path, error)
    json = JSON.pretty_generate(diagnostic(path, error))
    warn(json)
    $stderr.flush
    html_json(status, json)
  end

  def html_json(status, json)
    [status, { 'Content-Type' => 'application/json' }, [json]]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, error)
    { 'exception' => {
      'time' => Time.now,
      'path' => path,
      'class' => 'DifferService',
      'message' => error.message
    } }
  end

  # - - - - - - - - - - - - - - - -

  CONTENT_TYPE_JSON = { 'Content-Type' => 'application/json' }.freeze
end
