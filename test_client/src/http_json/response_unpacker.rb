require 'json'

module HttpJson

  class ResponseUnpacker

    def initialize(requester, exception_class)
      @requester = requester
      @exception_class = exception_class
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.body, path.to_s)
    rescue => error
      fail @exception_class, error.message
    end

    private

    def unpacked(body, path)
      json = json_parse(body)
      unless json.is_a?(Hash)
        # :nocov:
        fail error_msg(body, 'is not JSON Hash')
        # :nocov:
      end
      if json.has_key?('exception')
        fail JSON.pretty_generate(json['exception'])
      end
      unless json.has_key?(path)
        # :nocov:
        fail error_msg(body, "has no key for '#{path}'")
        # :nocov:
      end
      json[path]
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def json_parse(body)
      JSON.parse(body)
    rescue JSON::ParserError
      # :nocov:
      fail error_msg(body, 'is not JSON')
      # :nocov:
    end

    # - - - - - - - - - - - - - - - - - - - - -

    def error_msg(body, text)
      # :nocov:
      "http response.body #{text}:#{body}"
      # :nocov:
    end

  end

end
