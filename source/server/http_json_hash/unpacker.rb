# frozen_string_literal: true

require_relative 'service_error'
require 'json'

module HttpJsonHash
  class Unpacker
    def initialize(name, requester)
      @name = name
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s, args)
    end

    private

    def unpacked(body, path, args)
      json = JSON.parse!(body)
      raise service_error(path, args, body, 'body is not JSON Hash') unless json.instance_of?(Hash)
      raise service_error(path, args, body, json['exception']) if json.key?('exception')

      name = argless(path)
      raise service_error(path, args, body, "body is missing #{name} key") unless json.key?(name)

      json[name]
    rescue JSON::ParserError
      raise service_error(path, args, body, 'body is not JSON')
    end

    def argless(path)
      s = path.split('?')[0]
      path == "#{s}?" ? path : s
    end

    def service_error(path, args, body, message)
      ::HttpJsonHash::ServiceError.new(@name, path, args, body, message)
    end
  end
end
