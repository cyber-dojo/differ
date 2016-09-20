
# NB: if you call this file app.rb then SimpleCov fails to see it?!
#     or rather, it botches its appearance in the html view where it
#     appears as src..rb with two dots

require 'sinatra/base'
require 'json'

require_relative './differ'
require_relative './git_diff'

class MicroService < Sinatra::Base

  get '/diff' do
    content_type :json
    request.body.rewind
    @args = JSON.parse(request.body.read)
    was_files = @args['was_files']
    now_files = @args['now_files']
    diff = Differ.new(was_files, now_files).diff
    git_diff(diff, now_files).to_json
  end

  private

  include GitDiff

end


