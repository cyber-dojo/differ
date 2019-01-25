require_relative 'differ_test_base'

class DiffTest < DifferTestBase

  def self.hex_prefix
    'FCF'
  end

  test '3DA',
  'was_files is empty, now_files is empty' do
    diff = with_captured_stdout { diff({}, {}) }
    assert_equal({}, diff)
  end

end
