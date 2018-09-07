require_relative 'client_error'
require_relative 'differ'
require_relative 'externals'
require 'json'
require 'rack'

class RackDispatcher

  def call(env)
    differ = Differ.new(self)
    request = Rack::Request.new(env)
    name, args = validated_name_args(request)
    result = differ.public_send(name, *args)
    json_response(200, { name => result })
  rescue => error
    info = {
      'class' => error.class.name,
      'exception' => error.message,
      'trace' => error.backtrace,
    }
    $stderr.puts pretty(info)
    $stderr.flush
    json_response(status(error), info)
  end

  private

  include Externals

  def validated_name_args(request)
    @args = JSON.parse(request.body.read)
    name = request.path_info[1..-1] # lose leading /
    args = case name
      when /^sha$/   then []
      when /^diff$/  then [was_files, now_files]
      else
        raise ClientError, 'json:malformed'
    end
    [name, args]
  end

  # - - - - - - - - - - - - - - - -

  def json_response(status, body)
    [ status, { 'Content-Type' => 'application/json' }, [ pretty(body) ] ]
  end

  def pretty(o)
    JSON.pretty_generate(o)
  end

  def status(error)
    error.is_a?(ClientError) ? 400 : 500
  end

  # - - - - - - - - - - - - - - - -

  def self.request_args(*names)
    names.each { |name|
      define_method name, &lambda { @args[name.to_s] }
    }
  end

  request_args :was_files, :now_files

end
