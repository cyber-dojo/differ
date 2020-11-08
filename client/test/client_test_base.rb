require_relative 'lib/id58_test_base'
require_app 'differ_service'
require_app 'model_service'

class ClientTestBase < Id58TestBase

  def initialize(arg)
    super(arg)
  end

  def differ
    @differ ||= External::DifferService.new
  end

  def model
    @model ||= External::ModelService.new
  end

end
