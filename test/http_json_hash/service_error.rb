# frozen_string_literal: true

module Test; end
module Test::HttpJsonHash

  class ServiceError < RuntimeError

    def initialize(path, args, name, body, message)
      @path = path
      @args = args
      @name = name
      @body = body
      super(message)
    end

    attr_reader :path, :args, :name, :body

  end

end