require 'json'

module Test::HttpJsonHash

  class Unpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      json = JSON.parse!(response.body)
      keyed_for_now(json, path)
    end

    def post(path, args)
      response = @requester.post(path, args)
      json = JSON.parse!(response.body)
      keyed_for_now(json, path)
    end

    private

    def keyed_for_now(json, path)
      path = path.to_s
      json[path]
    end

  end

end
