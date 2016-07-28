require 'sinatra'
require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  get '/' do
    'Talk to differ_server by getting ENV'
  end
end


