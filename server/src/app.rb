
require 'sinatra/base'
require 'json'

require_relative './differ'

class App < Sinatra::Base

  get '/diff' do
    differ.diff.to_json
  end

  private

  def differ; Differ.new(was_files, now_files); end
  def was_files; json('was_files'); end
  def now_files; json('now_files'); end
  def json(name); JSON.parse(params[name]); end

end


