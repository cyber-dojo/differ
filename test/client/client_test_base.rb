require_relative 'lib/id58_test_base'
require_app 'differ'

class ClientTestBase < Id58TestBase
  def differ
    @differ ||= External::Differ.new
  end
end
