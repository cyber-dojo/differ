# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalModel

  def initialize(http)
    service = 'model'
    port = ENV['CYBER_DOJO_MODEL_PORT'].to_i
    @http = HttpJsonHash::service(self.class.name, http, service, port)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - - -

=begin
  def kata_event(id, index)
    @http.get(__method__, {
      id:id,
      index:index
    })
  end
=end

end
