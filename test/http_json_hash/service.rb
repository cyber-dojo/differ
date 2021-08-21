require_relative 'requester'
require_relative 'unpacker'

module Test::HttpJsonHash

  def self.service(hostname, port)
    requester = ::Test::HttpJsonHash::Requester.new(hostname, port)
    ::Test::HttpJsonHash::Unpacker.new(requester)
  end

end
