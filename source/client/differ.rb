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

    # - - - - - - - - - - - - - - - - - - -

    def diff_lines(was_files:, now_files:)
      @http.get(__method__, {
                  was_files: was_files,
                  now_files: now_files
                })
    end

    def diff_summary(was_files:, now_files:)
      @http.get(__method__, {
                  was_files: was_files,
                  now_files: now_files
                })
    end
  end
end
