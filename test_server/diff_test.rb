require_relative 'differ_test_base'

class DiffTest < DifferTestBase

  def self.hex_prefix
    'FCF'
  end

  test '3DA',
  'was_files is empty, now_files is empty' do
    assert_equal({}, differ.diff({}, {}))
  end

end
