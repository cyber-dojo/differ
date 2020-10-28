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
    params = request.params
    name,args = HttpJsonArgs.new.get(path)
    result = @differ.public_send(name, *args)
    html_json_pass(200, { name => result })
  rescue HttpJson::RequestError => error
    html_json_fail(400, path, params, error)
  rescue Exception => error
    html_json_fail(500, path, params, error)
  end

  private

  def html_json_pass(status, result)
    json = JSON.fast_generate(result)
    html_json(status, json)
  end

  def html_json_fail(status, path, params, error)
    json = JSON.pretty_generate(diagnostic(path, error))
    if path === '/ready' && params['log'] == 'file'
      IO.write("/tmp/ready.fail.log", json, mode:'a')
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
