require_relative '../lib/id58_test_base'
require_src 'externals'
require_src 'differ'

class DifferTestBase < Id58TestBase

  def initialize(arg)
    super(arg)
  end

  # Don't create a diff() method here as it interferes with MiniTest::Test!

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
