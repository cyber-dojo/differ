require_relative 'differ_test_base'

class ShaTest < DifferTestBase

  def self.hex_prefix
    'FB359'
  end

  # - - - - - - - - - - - - - - - - -

  test '191', %w(
  sha of git commit for server image lives in /app/sha.txt ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

end
