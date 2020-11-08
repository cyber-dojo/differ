# frozen_string_literal: true
require_relative 'requester'
require_relative 'unpacker'

module HttpJsonHash

  def self.service(hostname, port)
    requester = Requester.new(hostname, port)
    Unpacker.new(requester)
  end

end
