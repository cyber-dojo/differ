require_relative 'differ_test_base'

class DiffTest < DifferTestBase

  def self.hex_prefix
    'FCF'
  end

  test '3DA',
  'old_files is empty, new_files is empty' do
    expected = { 'diff' => {} }
    actual = differ.diff(id:hex_test_id, old_files:{}, new_files:{})
    assert_equal expected, actual
  end

end
