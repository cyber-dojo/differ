require_relative 'differ_test_base'
require 'ostruct'

class ProberTest < DifferTestBase

  test '198601', %w[alive] do
    assert true?(prober.alive)
  end

  test '198603', %w[ready] do
    assert true?(prober.ready)
  end

  test '198191', %w[sha] do
    sha = prober.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  def true?(arg)
    arg.instance_of?(TrueClass)
  end

end
