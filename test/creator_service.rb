# frozen_string_literal: true
require_relative 'http_json_hash/service'
require 'cgi'

module External

  class CreatorService

    def initialize
      name = 'creator'
      port = ENV['CYBER_DOJO_CREATOR_PORT'].to_i
      @http = Test::HttpJsonHash::service(self.class.name, name, port)
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
      encoded = args.map{|name,value|
        "#{name}=#{CGI::escape(value)}"
      }.join('&')
      path = __method__.to_s + '?' + encoded
      @http.get(path, {})
    end

  end

end
