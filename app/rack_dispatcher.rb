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
    html_json_pass(200, result)
  rescue HttpJsonArgs::RequestError => caught
    html_json_fail(400, path, params, body, caught)
  rescue Exception => caught
    html_json_fail(500, path, params, body, caught)
  end

  private

  def html_json_pass(status, result)
    html_json(status, JSON.fast_generate(result))
  end

  def html_json_fail(status, path, params, body, caught)
    json = JSON.pretty_generate(diagnostic(path, params, body, caught))
    if path === '/ready'
      IO.write("/tmp#{path}.fail.log", json)
    else
      $stderr.puts(json)
      $stderr.flush
    end
    html_json(status, json)
  end

  def html_json(status, json)
    [ status, { 'Content-Type' => 'application/json' }, [json] ]
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

end
