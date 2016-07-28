require 'sinatra'
require 'sinatra/base'
require 'json'
require 'net/http'

# DifferClient
class App < Sinatra::Base

  get '/' do
    differ_server = ENV['DIFFER_SERVER_PORT']
    addr = differ_server.sub('tcp', 'http') + '/differ'
    uri = URI(addr)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path, 'Content-Type' => 'application/json')

    req.body = { name: 'John Doe', role: 'agent' }.to_json

    res = http.request(req)
    res.body
  end

end


