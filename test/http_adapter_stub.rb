# frozen_string_literal: true
require 'ostruct'

class HttpAdapterStub

  def initialize(body)
    @body = body
  end

  def get(_uri)
    OpenStruct.new
  end

  def start(_hostname, _port, _req)
    self
  end

  attr_reader :body

end
