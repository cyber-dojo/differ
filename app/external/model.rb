# frozen_string_literal: true
require_relative '../http_json_hash/service'

module External

  class Model

    def initialize(http)
      hostname = 'model'
      port = ENV['CYBER_DOJO_MODEL_PORT'].to_i
      @http = HttpJsonHash::service(self.class.name, http, hostname, port)
    end

    def ready?
      @http.get(__method__, {})
    end

    def kata_event(id, index)
      @http.get(__method__, { id:id, index:index })
    end

  end

end
