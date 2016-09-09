require 'sinatra'
require 'sinatra/base'
require 'json'

require_relative './lib/differ'
require_relative './lib/externals'

class App < Sinatra::Base

  get '/diff' do
    content_type :json
    differ.diff(was_files, now_files).to_json
  end

  private

  def was_files; arg['was_files']; end
  def now_files; arg['now_files']; end
  def arg; @arg ||= JSON.parse(request.body.read); end

  def differ; Differ.new(self); end

  include Externals

end


