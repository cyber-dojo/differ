require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ'

class DifferTestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def diff(was_files, now_files)
    differ.diff(was_files, now_files)
  end

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

  # - - - - - - - - - - - - - - - - - - -

=begin
  def with_captured_stderr
    result = nil
    @stderr = ''
    begin
      old_stderr = $stderr
      $stderr = StringIO.new('', 'w')
      result = yield
      @stderr = $stderr.string
    ensure
      $stderr = old_stderr
    end
    result
  end
=end

end
