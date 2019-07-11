require_relative 'differ_test_base'

class ReadyTest < DifferTestBase

  def self.hex_prefix
    '0B2'
  end

  # - - - - - - - - - - - - - - - - -

  test '602',
  %w( its ready ) do
    assert differ.ready?
  end

end
