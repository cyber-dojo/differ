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
      unless json.instance_of?(Hash)
        fail service_error(path, args, body, 'body is not JSON Hash')
      end
      if json.has_key?('exception')
        fail service_error(path, args, body, 'body has embedded exception')
      end
      name = argless(path)
      unless json.has_key?(name)
        fail service_error(path, args, body, "body is missing #{name} key")
      end
      json[name]
    rescue JSON::ParserError
      fail service_error(path, args, body, 'body is not JSON')
    end

    def argless(path)
      s = path.split('?')[0]
      path === s+'?' ? path : s
    end

    def service_error(path, args, body, message)
      ::HttpJsonHash::ServiceError.new(@name, path, args, body, message)
    end

  end

end
