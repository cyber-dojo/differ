require_relative 'lib/id58_test_base'
require_app 'externals'
require_app 'differ'
require_app 'prober'

class DifferTestBase < Id58TestBase
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
