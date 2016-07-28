require 'sinatra'
require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  get '/diff' do
    content_type :json
    { :was => was, :now => now }.to_json
  end

  private

  def was
    arg['was']
  end

  def now
    arg['now']
  end

  def arg
    @arg ||= JSON.parse(request.body.read)
  end

end


