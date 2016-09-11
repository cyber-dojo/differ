
require 'minitest/autorun'

require_relative './external_helpers'
require_relative './hex_id_helpers'

class TestBase < MiniTest::Test

  include TestExternalHelpers
  include TestHexIdHelpers

end
