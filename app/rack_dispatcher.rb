# frozen_string_literal: true
require_relative 'http_json_args'
require 'json'

class RackDispatcher

  def initialize(differ, request_class)
    @differ = differ
    @request_class = request_class
  end

  # - - - - - - - - - - - - - - - -

  def call(env)
    request = @request_class.new(env)
    path = request.path_info
    params = request.params
    body = request.body.read
    result = HttpJsonArgs::dispatch(path, @differ, body, params)
    json_response_pass(200, result)
  rescue HttpJsonArgs::RequestError => caught
    json_response_fail(400, path, params, body, caught)
  rescue Exception => caught
    json_response_fail(500, path, params, body, caught)
  end

  private

  def json_response_pass(status, result)
    body = JSON.fast_generate(result)
    [ status, CONTENT_TYPE_JSON, [body] ]
  end

  # - - - - - - - - - - - - - - - -

  def json_response_fail(status, path, params, body, caught)
    body = JSON.pretty_generate(diagnostic(path, params, body, caught))
    if ['/alive','/ready'].include?(path)
      IO.write("/tmp#{path}.fail.log", body)
    else
      $stderr.puts(body)
      $stderr.flush
    end
    [ status, CONTENT_TYPE_JSON, [body] ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, params, body, caught)
    { 'exception' => {
        'time' => Time.now,
        'body' => body,
        'path' => path,
        'params' => params,
        'class' => 'DifferService',
        'message' => caught.message,
        'backtrace' => caught.backtrace
      }
    }
  end

  # - - - - - - - - - - - - - - - -

  CONTENT_TYPE_JSON = { 'Content-Type' => 'application/json' }

end
