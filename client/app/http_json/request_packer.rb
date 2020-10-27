# frozen_string_literal: true
require 'json'
require 'net/http'
require 'uri'

module HttpJson

  class RequestPacker

    def initialize(http, host, port)
      @http = http.new(host, port)
      @base_url = "http://#{host}:#{port}"
    end

    def get(path, args, options = {})
      req = request(path, args, options) do |url|
        Net::HTTP::Get.new(url)
      end
      @http.request(req)
    end

    private

    def request(path, args, options)
      if options[:gives] === :query
        req = yield URI.parse("#{@base_url}/#{path}#{query(args)}")
      else
        # default is currently to send GET args in request.body as JSON
        # because this was written when I new nothing about http
        req = yield URI.parse("#{@base_url}/#{path}")
        req.body = JSON.generate(args)
      end
      req.content_type = 'application/json'
      req
    end

    def query(args)
      '?' + args.map{ |key,value| "#{key}=#{value}" }.join('&')
    end

  end

end
