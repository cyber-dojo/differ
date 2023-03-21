# frozen_string_literal: true

require_relative 'lib/id58_test_base'
require_app 'differ'
require_app 'saver'

class ClientTestBase < Id58TestBase
  def differ
    @differ ||= External::Differ.new
  end

  def saver
    @saver ||= External::Saver.new
  end
end
