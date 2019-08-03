# frozen_string_literal: true

require_relative 'http_json/request_error'

class HttpJsonArgs

  def get(path)
    case path
    when '/ready' then ['ready?',[]]
    else
      raise HttpJson::RequestError, 'unknown path'
    end
  end

end
