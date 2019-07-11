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

  def log
    externals.log
  end

  def shell
    externals.shell
  end

  private

  def with_captured_stdout
    result = nil
    @stdout = ''
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      result = yield
      @stdout = $stdout.string
    ensure
      $stdout = old_stdout
    end
    result
  end

end
