require 'json'
require 'net/http'

module GitDiff # mix-in

  module_function

  def git_diff(was_files, now_files)
    uri = URI.parse('http://differ:4567')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = {
      :was_files => was_files,
      :now_files => now_files
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

end


