require_relative 'differ_test_base'

class ExternalsTest < DifferTestBase

  def self.id58_prefix
    '7A9'
  end

  test '920',
  'default disk is ExternalDiskWriter' do
    assert_equal External::DiskWriter, disk.class
  end

  # - - - - - - - - - - - - - - - - -

  test 'C8F',
  'default git is ExternalGitter' do
    assert_equal External::Gitter, git.class
  end

  # - - - - - - - - - - - - - - - - -

  test '1B1',
  'default shell is ExternalSheller' do
    assert_equal External::Sheller, shell.class
  end

end
