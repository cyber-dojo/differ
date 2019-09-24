require_relative 'differ_test_base'
require_relative '../src/base58'

class Base58Test < DifferTestBase

  def self.hex_prefix
    'F3A'
  end

  # - - - - - - - - - - - - - - - - - - -

  test '068', %w(
  string?(s) true ) do
    assert string?('012456789')
    assert string?('abcdefghjklmnpqrstuvwxyz') # no io
    assert string?('ABCDEFGHJKLMNPQRSTUVWXYZ') # no IO
  end

  # - - - - - - - - - - - - - - - - - - -

  test '069', %w(
  string?(s) false ) do
    refute string?(nil)
    refute string?([])
    refute string?(25)
    refute string?('£$%^&*()')
  end

  private

  def string?(s)
    Base58.string?(s)
  end

end
