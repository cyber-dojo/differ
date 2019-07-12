require_relative 'differ_test_base'

class ExternalsTest < DifferTestBase

  def self.hex_prefix
    '7A9'
  end

  test '920',
  'default disk is ExternalDiskWriter' do
    assert_equal 'ExternalDiskWriter', disk.class.name
  end

  test '921',
  'alternate disk can be substitited' do
    externals.disk = 'hello'
    assert_equal 'hello', externals.disk
    assert_equal 'hello', disk
  end

  # - - - - - - - - - - - - - - - - -

  test 'C8F',
  'default git is ExternalGitter' do
    assert_equal 'ExternalGitter', git.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '1B1',
  'default shell is ExternalSheller' do
    assert_equal 'ExternalSheller', shell.class.name
  end

  test '1B2',
  'alternate shell can be substituted' do
    externals.shell = 'gday'
    assert_equal 'gday', externals.shell
    assert_equal 'gday', shell
  end

end
