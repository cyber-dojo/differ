require 'sinatra/base'
require 'json'
require 'English'

class AppBase < Sinatra::Base
  def initialize(externals)
    @externals = externals
    super(nil)
  end

  set :port, ENV['PORT']
  set :host_authorization, { permitted_hosts: [] } # https://github.com/sinatra/sinatra/issues/2065#issuecomment-2484285707

  def self.get_json(name, klass)
    get "/#{name}", provides: [:json] do
      target = klass.new(@externals)
      result = { name => target.public_send(name, **named_args) }
      probe_compatible(name, result)
      content_type(:json)
      result.to_json
    end
  end

  private

  def named_args
    request.body.rewind
    args = json_hash_parse(request.body.read)
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
    request.body.rewind
    info = {
      exception: {
        time: Time.now,
        request: {
          path: request.path,
          params: request.params,
          body: request.body.read
        },
        message: error.message
      }
    }
    diagnostic = JSON.pretty_generate(info)
    puts(diagnostic)
    body(diagnostic)
  end
end
