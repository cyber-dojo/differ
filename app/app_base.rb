require_relative 'silently'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'http_json_hash/service'
require 'json'

class AppBase < Sinatra::Base

  def initialize(externals)
    @externals = externals
    super(nil)
  end

  silently { register Sinatra::Contrib } # respond_to
  set :port, ENV['PORT']

  def self.get_json(name, klass)
    get "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          target = klass.new(@externals)
          result = { name => target.public_send(name, **named_args) }
          probe_compatible(name, result)
          json(result)
        }
      end
    end
  end

  private

  def named_args
    if params.empty?
      args = json_hash_parse(request.body.read)
    else
      args = params
    end
    Hash[args.map{ |key,value| [key.to_sym, value] }]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def json_hash_parse(body)
    if body === ''
      body = '{}'
    end
    json = JSON.parse!(body)
    unless json.instance_of?(Hash)
      fail 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def probe_compatible(name, result)
    if [:alive, :ready].include?(name)
      sym = (name.to_s + '?').to_sym
      result[sym] = result[name]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $!
    status(500)
    content_type('application/json')
    info = {
      exception: {
        time: Time.now,
        request: {
          path:request.path,
          params:request.params,
          body:request.body.read
        }
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        name:error.name,
        path:error.path,
        args:error.args,
        body:error.body,
        message:error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = JSON.pretty_generate(info)
    puts(diagnostic)
    body(diagnostic)
  end

end
