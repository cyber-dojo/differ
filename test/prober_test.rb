require_relative 'differ_test_base'

class ProberTest < DifferTestBase

  def self.id58_prefix
    '198'
  end

  # - - - - - - - - - - - - - - - - -
  test '191', %w( sha ) do
    sha = prober.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  test '601', %w( alive ) do
    assert true?(prober.alive)
  end

  test '602', %w( healthy ) do
    assert true?(prober.healthy)
  end

  test '603', %w( ready ) do
    assert true?(prober.ready)
  end

  # - - - - - - - - - - - - - - - - -

  test '604', %w(
  |when model http-proxy is not ready
  |then ready? is false
  ) do
    externals.instance_exec { @model=STUB_READY_FALSE }
    assert false?(prober.ready)
  end

  private

  STUB_READY_FALSE = OpenStruct.new(:ready? => false)

  def true?(b)
    b.instance_of?(TrueClass)
  end

  def false?(b)
    b.instance_of?(FalseClass)
  end

end
