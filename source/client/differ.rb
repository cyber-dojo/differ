# frozen_string_literal: true

require_relative 'http_json_hash/service'

module External
  class Differ
    def initialize
      hostname = 'server'
      port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
      @http = HttpJsonHash.service('differ', hostname, port)
    end

    def alive
      @http.get(__method__, {})
    end

    def ready
      @http.get(__method__, {})
    end

    def sha
      @http.get(__method__, {})
    end

    def base_image
      @http.get(__method__, {})
    end

    # - - - - - - - - - - - - - - - - - - -

    def diff_lines(id, was_index, now_index)
      @http.get(__method__, {
                  id: id,
                  was_index: was_index,
                  now_index: now_index
                })
    end

    def diff_summary(id, was_index, now_index)
      @http.get(__method__, {
                  id: id,
                  was_index: was_index,
                  now_index: now_index
                })
    end
  end
end
