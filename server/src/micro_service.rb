require 'json'

require_relative 'externals'
require_relative 'git_differ'
require_relative 'git_diff_join'

class MicroService

  def call(env)
    request = Rack::Request.new(env)
    @args = JSON.parse(request.body.read)
    [ 200, { 'Content-Type' => 'application/json' }, [ json ] ]
  end

  private

  include Externals
  include GitDiffJoin

  def json
    diff = GitDiffer.new(self).diff(was_files, now_files)
    { 'diff' => git_diff_join(diff, now_files) }.to_json
  rescue Exception => e
    log << "EXCEPTION: #{e.class.name} #{e.to_s}"
    { 'exception' => e.class.name }.to_json
  end

  def self.request_args(*names)
    names.each { |name|
      define_method name, &lambda { @args[name.to_s] }
    }
  end

  request_args :was_files, :now_files

end
