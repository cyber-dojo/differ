require_relative '../id58_test_base'
require_src 'externals'
require_src 'differ_service'

class ClientTestBase < Id58TestBase

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
