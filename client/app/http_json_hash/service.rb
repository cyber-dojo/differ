require_relative 'requester'
require_relative 'unpacker'

module HttpJsonHash

  def self.service(name, hostname, port)
    requester = Requester.new(hostname, port)
    Unpacker.new(name, requester)
  end

end
