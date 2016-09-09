require 'sinatra'
require 'sinatra/base'
require 'json'
require 'net/http'

class App < Sinatra::Base

  get '/diff' do
    differ_server = ENV['DIFFER_PORT']
    addr = differ_server.sub('tcp', 'http') + '/diff'
    uri = URI(addr)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path, 'Content-Type' => 'application/json')

    was_files = {
      'cyber-dojo.sh': "blah blah",
      'hiker.c': '#include <hiker.h>',
      'deleted.txt': 'tweedle-dee',
      'compacted.eg':
        [ "def finalize(values)",
          "",
          "  values.each do |v|",
          "    v.finalize",
          "  end",
          "",
          "end"
        ].join("\n")
    }
    now_files = {
      'cyber-dojo.sh': "blah blah blah",
      'hiker.c': '#include "hiker.h"',
      'hiker.h': '#ifndef HIKER_INCLUDED\n#endif',
      'compacted.eg':
        [ "def finalize(values)",
          "",
          "  values.each do |v|",
          "    v.prepare",
          "  end",
          "",
          "  values.each do |v|",
          "    v.finalize",
          "  end",
          "",
          "end"
        ].join("\n")
    }
    req.body = { was_files: was_files, now_files: now_files }.to_json

    res = http.request(req)
    json = JSON.parse(res.body)
    '<pre>' + JSON.pretty_unparse(json) + '</pre>'
  end

end


