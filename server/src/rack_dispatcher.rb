require_relative 'client_error'
require_relative 'differ'
require_relative 'externals'
require 'json'
require 'rack'

class RackDispatcher

  def call(env)
    request = Rack::Request.new(env)
    name, args = name_args(request)
    differ = Differ.new(self)
    result = differ.send(name, *args)
    json_triple(200, { name => result })
  rescue => error
    info = {
      'exception' => error.message,
      'trace' => error.backtrace,
    }
    #external.log << to_json(info)
    json_triple(code_400_500(error), info)
  end

  private

  include Externals

  def name_args(request)
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

  def json_triple(code, body)
    [ code, { 'Content-Type' => 'application/json' }, [ to_json(body) ] ]
  end

  def to_json(o)
    JSON.pretty_generate(o)
  end

  def code_400_500(error)
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
