# frozen_string_literal: true

require_relative 'http_json_args'
require 'json'

class RackDispatcher

  def initialize(differ, request_class)
    @differ = differ
    @request_class = request_class
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info
    body = request.body.read
    name,args = HttpJsonArgs.new(body).get(path)
    json_response_pass(200, @differ.public_send(name, *args))
  rescue HttpJsonArgs::Error => caught
    json_response_fail(400, path, body, caught)
  rescue Exception => caught
    json_response_fail(500, path, body, caught)
  end

  private

  CONTENT_TYPE_JSON = { 'Content-Type' => 'application/json' }

  def json_response_pass(status, result)
    s = JSON.fast_generate(result)
    [ status, CONTENT_TYPE_JSON, [s] ]
  end

  def json_response_fail(status, path, body, caught)
    s = JSON.pretty_generate(diagnostic(path, body, caught))
    $stderr.puts(s)
    $stderr.flush
    [ status, CONTENT_TYPE_JSON, [s] ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, body, caught)
    { 'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'DifferService',
        'message' => caught.message,
        'backtrace' => caught.backtrace
      }
    }
  end

end
