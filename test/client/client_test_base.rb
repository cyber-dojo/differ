require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ_service'

class ClientTestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def differ
    @differ ||= DifferService.new(externals)
  end

end
