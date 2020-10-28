# frozen_string_literal: true
require_relative 'http_json/request_error'
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
    name,args = HttpJsonArgs.new.get(path)
    result = @differ.public_send(name, *args)
    json_response_pass(200, { name => result })
  rescue HttpJson::RequestError => error
    json_response_fail(400, path, error)
  rescue Exception => error
    json_response_fail(500, path, error)
  end

  private

  def json_response_pass(status, json)
    body = JSON.fast_generate(json)
    [ status, CONTENT_TYPE_JSON, [ body ] ]
  end

  def json_response_fail(status, path, error)
    json = diagnostic(path, error)
    body = JSON.pretty_generate(json)
    if ['/alive','/ready'].include?(path)
      IO.write("/tmp#{path}.fail.log", body)
    else
      $stderr.puts(body)
      $stderr.flush
    end
    [ status, CONTENT_TYPE_JSON, [ body ] ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, error)
    { 'exception' => {
        'path' => path,
        'class' => 'DifferService',
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    }
  end

  # - - - - - - - - - - - - - - - -

  CONTENT_TYPE_JSON = { 'Content-Type' => 'application/json' }

end
