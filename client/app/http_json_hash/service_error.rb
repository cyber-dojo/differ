require 'json'

module HttpJsonHash

  class ServiceError < RuntimeError

    def initialize(name, path, args, body, message)
      super(JSON.pretty_generate({
        request:{
          service:name,
          path:path,
          args:args
        },
        response: {
          body:body
        },
        message:message
      }))
    end

  end

end
