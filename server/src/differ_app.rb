
# NB: if you call this file app.rb then SimpleCov fails to see it?!
#     or rather, it botches its appearance in the html view where it
#     appears as src..rb

require 'sinatra/base'
require 'json'

require_relative './differ'

class DifferApp < Sinatra::Base

  get '/diff' do
    differ.diff.to_json
  end

  private

  def differ; Differ.new(was_files, now_files); end
  def was_files; json('was_files'); end
  def now_files; json('now_files'); end
  def json(name); JSON.parse(params[name]); end

end


