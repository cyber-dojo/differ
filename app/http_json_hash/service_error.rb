module HttpJsonHash

  class ServiceError < RuntimeError

    def initialize(name, path, args, body, message)
      @name = name
      @path = path
      @args = args
      @body = body
      super(message)
    end

    attr_reader :name, :path, :args, :body

  end

end
