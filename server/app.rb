require 'sinatra'
require 'sinatra/base'
require 'json'

require_relative './lib/differ'

class App < Sinatra::Base

  get '/diff' do
    content_type :json
    differ.diff.to_json
  end

  private

  def differ; Differ.new(was_files, now_files); end
  def was_files; arg['was_files']; end
  def now_files; arg['now_files']; end
  def arg; @arg ||= JSON.parse(request.body.read); end

end


