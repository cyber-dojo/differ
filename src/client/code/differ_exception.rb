require_relative 'http_json/service_exception'

class DifferException < HttpJson::ServiceException

  def initialize(message)
    super
  end

end
