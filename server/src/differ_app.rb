
# NB: if you call this file app.rb then SimpleCov fails to see it?!
#     or rather, it botches its appearance in the html view where it
#     appears as src..rb

require 'sinatra/base'
require 'json'

require_relative './differ'

class DifferApp < Sinatra::Base

  get '/diff' do
    was_files = JSON.parse(params['was_files'])
    now_files = JSON.parse(params['now_files'])
    Differ.new(was_files, now_files).diff.to_json
  end

end


