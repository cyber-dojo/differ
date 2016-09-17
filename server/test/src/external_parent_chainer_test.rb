
require_relative './lib_test_base'
require_relative './spy_logger'

class ExternalParentChainerTest < LibTestBase

  def self.hex(suffix)
    '397' + suffix
  end

  def setup
    super
    @edna = GrandMother.new
    @margaret = Mother.new(@edna)
    @ellie = Daughter.new(@margaret)
  end

  attr_reader :edna, :margaret, :ellie

  # - - - - - - - - - - - - - - - - - - - - -

  test 'B16',
  'root object has no parent, does not include chainer, has accessible externals (eg log)' do
    edna.log << 'Tay'
    assert_equal ['Tay'], edna.log.spied
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '467',
  'objects are chained together using parent and paths use parent property' do
    assert_equal 'Daughter', ellie.class.name
    assert_equal 'Mother', ellie.parent.class.name
    assert_equal 'GrandMother', ellie.parent.parent.class.name
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '1A8',
  'method_missing finds first object without a parent and delegates to it' do
    ellie.method(42)
    ellie.method('hello')
    assert_equal [42,'hello'], edna.log.spied
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'F52',
  'parent chain is for dot *access* only - passing args raises RuntimeError' do
    assert_equal [], ellie.log.spied
    raised = assert_raises(RuntimeError) { ellie.log(42) }
    assert_equal "not-expecting-arguments [42]", raised.message
  end

end

# - - - - - - - - - - - - - - - -

class GrandMother

  def log; @log ||= SpyLogger.new(self); end

end

# - - - - - - - - - - - - - - - -

class Mother

  def initialize(grandmother)
    @parent = grandmother
  end

  attr_reader :parent

  private

  include ExternalParentChainer

end

# - - - - - - - - - - - - - - - -

class Daughter

  def initialize(mother)
    @parent = mother
  end

  attr_reader :parent

  def method(arg)
    log << arg
  end

  private

  include ExternalParentChainer

end
