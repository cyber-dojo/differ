require_relative 'lib/id58_test_base'
require_relative 'saver'
require_app 'externals'
require_app 'differ'
require_app 'prober'

class DifferTestBase < Id58TestBase
  def initialize(arg)
    super(arg)
  end

  # Don't create a diff() method here as it interferes with MiniTest::Test!

  def externals
    @externals ||= Externals.new
  end

  def differ
    @differ ||= Differ.new(externals)
  end

  def prober
    @prober ||= Prober.new(externals)
  end

  def saver
    # local because tests need more of model's API.
    @saver ||= ::Test::Saver.new
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
