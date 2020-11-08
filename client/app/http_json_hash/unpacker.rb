# frozen_string_literal: true
require 'json'

module HttpJsonHash

  class Unpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body)
    end

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body)
    end

    private

    def unpacked(body)
      json = JSON.parse!(body)
      if json.is_a?(Hash) && json.has_key?('exception')
        fail JSON.pretty_generate(json['exception'])
      end
      json
    end

  end

end
