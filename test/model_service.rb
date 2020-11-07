# frozen_string_literal: true
require_relative 'http_json_hash/service'

module External

  class ModelService

    def initialize
      hostname = 'model'
      port = ENV['CYBER_DOJO_MODEL_PORT'].to_i
      @http = Test::HttpJsonHash::service(hostname, port)
    end

    # - - - - - - - - - - - - - - - - - - -

    def ready?
      @http.get(__method__, {})
    end

    # - - - - - - - - - - - - - - - - - - -

    def kata_create(manifest)
      @http.post(__method__, {
        manifest:manifest,
        options:{}
      })
    end

    # - - - - - - - - - - - - - - - - - - -

    def kata_ran_tests(id, index, files, stdout, stderr, status, summary)
      @http.post(__method__, {
        id:id,
        index:index,
        files:files,
        stdout:stdout,
        stderr:stderr,
        status:status,
        summary:summary
      })
    end

  end

end
