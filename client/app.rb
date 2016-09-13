require 'sinatra'
require 'sinatra/base'
require 'json'
require 'net/http'

class App < Sinatra::Base

  get '/diff' do

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
      'hiker.h': "#ifndef HIKER_INCLUDED\n#endif",
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

    params = {
      :was_files => was_files.to_json,
      :now_files => now_files.to_json
    }

    uri = URI.parse(ENV['DIFFER_PORT'].sub('tcp', 'http') + '/diff')
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    json = JSON.parse(response.body)
    '<pre>' + JSON.pretty_unparse(json) + '</pre>'

  end

end


