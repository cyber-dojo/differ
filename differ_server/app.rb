require 'sinatra'
require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  get '/' do
    content_type :json
    { :key1 => 'Hello from docker!' }.to_json
  end
end


