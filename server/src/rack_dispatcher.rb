require_relative 'externals'
require_relative 'git_differ'
require_relative 'git_diff_join'
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
  include GitDiffJoin

  def diff
    git_diff = GitDiffer.new(self).diff(was_files, now_files)
    { 'diff' => git_diff_join(git_diff, now_files) }
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
