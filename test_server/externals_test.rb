require_relative 'differ_test_base'

class ExternalsTest < DifferTestBase

  def self.hex_prefix
    '7A9'
  end

  test '920',
  'default disk is ExternalDiskWriter' do
    assert_equal ExternalDiskWriter, disk.class
  end

  class AlternateDisk; end

  test '921',
  'alternate disk can be substitited' do
    externals.disk = AlternateDisk.new
    assert_equal AlternateDisk, externals.disk.class
    assert_equal AlternateDisk, disk.class
  end

  # - - - - - - - - - - - - - - - - -

  test 'C8F',
  'default git is ExternalGitter' do
    assert_equal ExternalGitter, git.class
  end

  # - - - - - - - - - - - - - - - - -

  test '1B1',
  'default shell is ExternalSheller' do
    assert_equal ExternalSheller, shell.class
  end

  class AlternateShell; end

  test '1B2',
  'alternate shell can be substituted' do
    externals.shell = AlternateShell.new
    assert_equal AlternateShell, externals.shell.class
    assert_equal AlternateShell, shell.class
  end

end
