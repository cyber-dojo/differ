require_relative 'silently'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require_relative 'http_json_hash/service'
require 'json'
require 'English'

class AppBase < Sinatra::Base
  def initialize(externals)
    @externals = externals
    super(nil)
  end

  silently { register Sinatra::Contrib } # respond_to
  set :port, ENV['PORT']

  def self.get_json(name, klass)
    get "/#{name}", provides: [:json] do
      respond_to do |format|
        format.json do
          target = klass.new(@externals)
          result = { name => target.public_send(name, **named_args) }
          probe_compatible(name, result)
          json(result)
        end
      end
    end
  end

  private

  def named_args
    args = if params.empty?
             json_hash_parse(request.body.read)
           else
             params
           end
    Hash[args.map { |key, value| [key.to_sym, value] }]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def json_hash_parse(body)
    body = '{}' if body == ''
    json = JSON.parse!(body)
    raise 'body is not JSON Hash' unless json.instance_of?(Hash)

    json
  rescue JSON::ParserError
    raise 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def probe_compatible(name, result)
    return unless %i[alive ready].include?(name)

    sym = "#{name}?".to_sym
    result[sym] = result[name]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $ERROR_INFO
    status(500)
    content_type('application/json')
    info = {
      exception: {
        time: Time.now,
        request: {
          path: request.path,
          params: request.params,
          body: request.body.read
        }
      }
    }
    exception = info[:exception]
    if error.instance_of?(::HttpJsonHash::ServiceError)
      exception[:http_service] = {
        name: error.name,
        path: error.path,
        args: error.args,
        body: error.body,
        message: error.message
      }
    else
      exception[:message] = error.message
    end
    diagnostic = JSON.pretty_generate(info)
    puts(diagnostic)
    body(diagnostic)
  end
end
