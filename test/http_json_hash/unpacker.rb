# frozen_string_literal: true
#require_relative 'service_error'
require 'json'

module Test::HttpJsonHash

  class Unpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      JSON.parse!(response.body)
    end

    def post(path, args)
      response = @requester.post(path, args)
      JSON.parse!(response.body)
    end

  end

end