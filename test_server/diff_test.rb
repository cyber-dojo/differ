require_relative 'differ_test_base'

class DiffTest < DifferTestBase

  def self.hex_prefix
    'FCF'
  end

  test '3DA',
  'old_files is empty, new_files is empty' do
    assert_equal({}, differ.diff(hex_test_id, {}, {}))
  end

end
