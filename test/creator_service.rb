# frozen_string_literal: true
require_relative 'http_json_hash/service'
require 'cgi'

module External

  class CreatorService

    def initialize
      hostname = 'creator'
      port = ENV['CYBER_DOJO_CREATOR_PORT'].to_i
      @http = Test::HttpJsonHash::service(hostname, port)
    end

    # - - - - - - - - - - - - - - - - - - -

    def ready?
      @http.get(__method__, {})
    end

    # - - - - - - - - - - - - - - - - - - -

    def build_manifest(exercise_name, language_name)
      args = {
        exercise_name:exercise_name,
        language_name:language_name
      }
      @http.get("#{__method__}?#{cgi_escaped(args)}", {})
    end

    private

    def cgi_escaped(args)
      args.map{|name,value|
        "#{name}=#{CGI::escape(value)}"
      }.join('&')
    end

  end

end
