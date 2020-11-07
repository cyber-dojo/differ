# frozen_string_literal: true
require_relative 'requester'
require_relative 'unpacker'

module Test::HttpJsonHash

  def self.service(name, hostname, port)
    requester = Requester.new(hostname, port)
    Unpacker.new(name, requester)
  end

end
