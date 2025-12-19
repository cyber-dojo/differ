# frozen_string_literal: true

require 'json'

module Test
  module HttpJsonHash
    class Unpacker
      def initialize(requester)
        @requester = requester
      end

      def get(path, args)
        response = @requester.get(path, args)
        unpacked(response.body, path.to_s, args)
      end

      def post(path, args)
        response = @requester.post(path, args)
        unpacked(response.body, path.to_s, args)
      end

      private

      def unpacked(body, path, _args)
        json = JSON.parse!(body)
        json[path]
      end
    end
  end
end
