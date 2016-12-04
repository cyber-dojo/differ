
require 'minitest/autorun'
require_relative '../external_helper'
require_relative '../hex_id_helper'

class DifferTestBase < MiniTest::Test

  include TestExternalHelper
  include TestHexIdHelper

end
