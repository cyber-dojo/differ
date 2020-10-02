# frozen_string_literal: true

module HttpJson

  class ServiceException < StandardError

    def initialize(message)
      super
    end

  end

end
