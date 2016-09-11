
require 'minitest/autorun'

require_relative './test_external_helpers'
require_relative './test_hex_id_helpers'

class TestBase < MiniTest::Test

  include TestExternalHelpers
  include TestHexIdHelpers

end
