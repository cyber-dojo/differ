require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ'

class DifferTestBase < HexMiniTest

  include Externals

  def sha
    Differ.new(self).sha
  end

end
