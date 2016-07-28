require 'sinatra'
require 'sinatra/base'
require 'json'

# DifferServer
class App < Sinatra::Base
  get '/differ' do

    p "/differ: received request..."

    content_type :json
    { :key1 => 'Hello from docker!' }.to_json
  end
end


