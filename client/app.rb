require 'sinatra'
require 'sinatra/base'
require 'json'
require 'net/http'

class App < Sinatra::Base

  get '/diff' do
    differ_server = ENV['DIFFER_SERVER_PORT']
    addr = differ_server.sub('tcp', 'http') + '/diff'
    uri = URI(addr)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path, 'Content-Type' => 'application/json')

    was_files = {
      'cyber-dojo.sh': "blah blah",
      'hiker.c': '#include <hiker.h>'
    }
    now_files = {
      'cyber-dojo.sh': "blah blah blah",
      'hiker.c': '#include "hiker.h"',
      'hiker.h': '#ifndef HIKER_INCLUDED\n#endif'
    }
    req.body = { was_files: was_files, now_files: now_files }.to_json

    res = http.request(req)
    res.body
  end

end


