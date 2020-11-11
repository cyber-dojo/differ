# frozen_string_literal: true
require_relative 'service_error'
require 'json'

module HttpJsonHash

  class Unpacker

    def initialize(name, requester)
      @name = name
      @requester = requester
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    end

    # - - - - - - - - - - - - - - - - - - - - -

    private

    def unpacked(body, path, args)
      json = JSON.parse!(body)
      if json.is_a?(Hash) && json.has_key?('exception')
        service_error(path, args, body, 'body has embedded exception')
      end
      if json.is_a?(Hash) && json.has_key?(path)
        json[path]
      else
        json
      end
    rescue JSON::ParserError
      service_error(path, args, body, 'body is not JSON')
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def service_error(path, args, body, message)
      fail ::HttpJsonHash::ServiceError.new(path, args, @name, body, message)
    end

  end

end
