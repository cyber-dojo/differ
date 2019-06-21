require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ'

class DifferTestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  include Externals

  def ready?
    differ.ready?
  end

  def sha
    differ.sha
  end

  def diff(was_files, now_files)
    differ.diff(was_files, now_files)
  end

  private

  def differ
    Differ.new(self)
  end

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
