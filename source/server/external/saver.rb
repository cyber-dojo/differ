# frozen_string_literal: true

require_relative '../http_json_hash/service'

module External
  class Saver
    def initialize(externals)
      hostname = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', 'saver')
      @port = ENV[port_env_var].to_i
      @http = HttpJsonHash.service(self.class.name, externals.saver_http, hostname, port)
    end

    attr_reader :port

    def ready?
      @http.get(__method__, {})
    end

    def kata_event(id, index)
      @http.get(__method__, { id: id, index: index })
    end

    private

    def port_env_var
      docker_port_env_var
    end

    def docker_port_env_var
      'CYBER_DOJO_SAVER_PORT'
    end
  end
end
