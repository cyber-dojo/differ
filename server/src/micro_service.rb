
# NB: if you call this file app.rb then SimpleCov fails to see it?!
#     or rather, it botches its appearance in the html view

require 'sinatra/base'
require 'json'

require_relative './git_differ'
require_relative './git_diff_join'
require_relative './externals'

class MicroService < Sinatra::Base

  get '/' do
    content_type :json
    was_files = args['was_files']
    now_files = args['now_files']
    diff = GitDiffer.new(self).diff(was_files, now_files)
    git_diff_join(diff, now_files).to_json
  end

  private

  include Externals
  include GitDiffJoin

  def args
    @args ||= request_body_args
  end

  def request_body_args
    request.body.rewind
    JSON.parse(request.body.read)
  end

end


