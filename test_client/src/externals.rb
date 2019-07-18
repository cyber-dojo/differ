require 'net/http'

class Externals

  def http
    @http ||= Net::HTTP
  end

end
