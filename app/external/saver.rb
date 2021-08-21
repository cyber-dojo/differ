require_relative '../http_json_hash/service'

module External

  class Saver

    def initialize(externals)
      hostname = 'saver'
      @port = ENV[port_env_var].to_i
      @http = HttpJsonHash::service(self.class.name, externals.saver_http, hostname, port)
    end

    attr_reader :port

    def ready?
      @http.get(__method__, {})
    end

    def kata_event(id, index)
      @http.get(__method__, { id:id, index:index })
    end

  private

    def port_env_var
      docker_port_env_var
    end

=begin
    def port_env_var
      if ENV.has_key?(k8s_port_env_var)
        k8s_port_env_var
      else
        docker_port_env_var
      end
    end

    def k8s_port_env_var
      'CYBER_DOJO_K8S_PORT'
    end
=end

    def docker_port_env_var
      'CYBER_DOJO_SAVER_PORT'
    end

  end

end
