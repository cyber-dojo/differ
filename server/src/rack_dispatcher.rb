require_relative 'differ'
require_relative 'externals'
require 'json'
require 'rack'

class RackDispatcher

  def call(env)
    request = Rack::Request.new(env)
    @args = JSON.parse(request.body.read)
    [ 200, { 'Content-Type' => 'application/json' }, [ diff.to_json ] ]
  end

  private

  include Externals

  def diff
    differ = Differ.new(self)
    { 'diff' => differ.diff(was_files, now_files) }
  rescue Exception => e
    log << "EXCEPTION: #{e.class.name} #{e.to_s}"
    { 'exception' => e.class.name }
  end

  def self.request_args(*names)
    names.each { |name|
      define_method name, &lambda { @args[name.to_s] }
    }
  end

  request_args :was_files, :now_files

end
