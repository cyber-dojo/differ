require_relative 'differ_test_base'

class AliveTest < DifferTestBase

  def self.id58_prefix
    '198'
  end

  # - - - - - - - - - - - - - - - - -

  test '93b',
  %w( its alive ) do
    assert differ.alive?
  end

end
