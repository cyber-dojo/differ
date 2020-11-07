# frozen_string_literal: true
require_relative 'http'
require_relative 'requester'
require_relative 'unpacker'

module Test module HttpJsonHash

  def self.service(name, hostname, port)
    http = Http.new
    requester = Requester.new(http, hostname, port)
    Unpacker.new(name, requester)
  end

end end
