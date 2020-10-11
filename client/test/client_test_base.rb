require_relative 'lib/id58_test_base'
require_app 'externals'
require_app 'differ_service'

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
