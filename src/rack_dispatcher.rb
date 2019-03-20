require_relative 'client_error'
require_relative 'differ'
require_relative 'externals'
require 'json'
require 'rack'

class RackDispatcher

  def initialize
    @differ = Differ.new(self)
    @request_class = Rack::Request
  end

  def call(env)
    request = @request_class.new(env)
    path = request.path_info[1..-1] # lose leading /
    body = request.body.read
    name, args = validated_name_args(path, body)
    result = @differ.public_send(name, *args)
    json_response(200, json_plain({ name => result }))
  rescue Exception => error
    diagnostic = json_pretty({
      'exception' => {
        'class' => error.class.name,
        'message' => error.message,
        'args' => body,
        'backtrace' => error.backtrace
      }
    })
    $stderr.puts(diagnostic)
    $stderr.flush
    json_response(status(error), diagnostic)
  end

  private

  include Externals

  def validated_name_args(name, body)
    @args = JSON.parse(body)
    args = case name
      when /^ready$/ then []
      when /^sha$/   then []
      when /^diff$/  then [was_files, now_files]
      else
        raise ClientError, 'json:malformed'
    end
    name += '?' if query?(name)
    [name, args]
  end

  # - - - - - - - - - - - - - - - -

  def json_plain(body)
    JSON.generate(body)
  end

  def json_pretty(body)
    JSON.pretty_generate(body)
  end

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  def status(error)
    error.is_a?(ClientError) ? 400 : 500
  end

  # - - - - - - - - - - - - - - - -

  def query?(name)
    ['ready'].include?(name)
  end

  # - - - - - - - - - - - - - - - -

  def self.request_args(*names)
    names.each { |name|
      define_method name, &lambda { @args[name.to_s] }
    }
  end

  request_args :was_files, :now_files

end
