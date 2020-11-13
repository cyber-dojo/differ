# frozen_string_literal: true
require_relative 'http_json_hash/service'

module External

  class ModelService

    def initialize
      hostname = 'model'
      port = ENV['CYBER_DOJO_MODEL_PORT'].to_i
      @http = HttpJsonHash::service('model', hostname, port)
    end

    # - - - - - - - - - - - - - - - - - - -

    def kata_create(manifest)
      @http.post(__method__, {
        manifest:manifest,
        options:{}
      })
    end

    def kata_manifest(id)
      @http.get(__method__, {
        id:id
      })
    end

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
