require 'sinatra'
require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  get '/diff' do

    hash = JSON.parse(request.body.read)
    p hash

    content_type :json
    { :key => 'was<-diff->now' }.to_json
  end
end


