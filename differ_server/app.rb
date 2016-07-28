require 'sinatra'
require 'sinatra/base'
require 'json'

# DifferServer
class App < Sinatra::Base
  get '/differ' do

    hash = JSON.parse(request.body.read)
    p hash

    content_type :json
    { :key => 'was diff now' }.to_json
  end
end


