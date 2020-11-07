# frozen_string_literal: true
require_relative 'service_error'
require 'json'

module Test::HttpJsonHash

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

    def post(path, args)
      response = @requester.post(path, args)
      unpacked(response.body, path.to_s, args)
    end

    # - - - - - - - - - - - - - - - - - - - - -

    private

    def unpacked(body, path, args)
      JSON.parse!(body)
    rescue JSON::ParserError
      service_error(path, args, body, 'body is not JSON')
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def service_error(path, args, body, message)
      fail ServiceError.new(path, args, @name, body, message)
    end

  end

end
