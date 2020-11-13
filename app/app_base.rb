# frozen_string_literal: true
require_relative 'silently'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require 'sinatra/contrib'
require_relative 'http_json_hash/service'
require_relative 'lib/json_adapter'
require 'json'
require 'sprockets'

class AppBase < Sinatra::Base

  def initialize(externals)
    @externals = externals
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(name, klass)
    get "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          target = klass.new(@externals)
          result = target.public_send(name, **args)
          content_type :json
          json({ name => result })
        }
      end
    end
  end

  private

  include JsonAdapter

  def args
    body = request.body.read
    if empty?(body)
      from = request.params
    else
      from = json_hash_parse(body)
    end
    symbolized(from)
  end

  def empty?(body)
    body === '' || body === '{}'
  end

  def symbolized(h)
    # named-args require symbolization
    Hash[h.map{ |key,value| [key.to_sym, value] }]
  end

  def json_hash_parse(body)
    json = JSON.parse!(body)
    unless json.instance_of?(Hash)
      fail 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $!
    status(500)
    content_type('application/json')
    info = {
      exception: {
        request: {
          path:request.path,
          body:request.body.read,
          params:request.params
        }
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        path:error.path,
        args:error.args,
        name:error.name,
        body:error.body,
        message:error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = json_pretty(info)
    puts diagnostic
    body diagnostic
  end

end
