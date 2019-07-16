require 'json'
require 'net/http'

module GitDiff # mix-in

  module_function

  def git_diff(old_files, new_files)
    uri = URI.parse("http://#{hostname}:#{port}/diff")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = {
      :old_files => old_files,
      :new_files => new_files
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end

  def hostname
    'differ-server'
  end

  def port
    4567
  end

end
