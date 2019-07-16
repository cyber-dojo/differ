require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ'

class DifferTestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  # Don't create a diff() method here as it interferes with MiniTest::Test

  def differ
    @differ ||= Differ.new(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  def disk
    externals.disk
  end

  def git
    externals.git
  end

  def shell
    externals.shell
  end

end
