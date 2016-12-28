require 'sinatra/base'
require 'json'

require_relative 'externals'
require_relative 'git_differ'
require_relative 'git_diff_join'

class MicroService < Sinatra::Base

  get '/diff' do
    differ
  end

  private

  include Externals
  include GitDiffJoin

  def differ
    diff = GitDiffer.new(self).diff(was_files, now_files)
    { 'diff' => git_diff_join(diff, now_files) }.to_json
  rescue Exception => e
    log << "EXCEPTION: #{e.class.name} #{e.to_s}"
    { 'exception' => e.class.name }.to_json
  end

  def self.request_args(*names)
    names.each { |name|
      define_method name, &lambda { args[name.to_s] }
    }
  end

  request_args :was_files, :now_files

  def args
    @args ||= JSON.parse(request_body_args)
  end

  def request_body_args
    request.body.rewind
    request.body.read
  end

end
