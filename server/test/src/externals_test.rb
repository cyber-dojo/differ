
require_relative './lib_test_base'

class ExternalsTest < LibTestBase

  def self.hex(suffix)
    '7A9' + suffix
  end

  include Externals

  test '920',
  'default file is ExternalFileWriter' do
    assert_equal 'ExternalFileWriter', disk.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test 'C8F',
  'default git is ExternalGitter' do
    assert_equal 'ExternalGitter', git.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '3EC',
  'default log is ExternalStdoutLogger' do
    assert_equal 'ExternalStdoutLogger', log.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '1B1',
  'default shell is ExternalSheller' do
    assert_equal 'ExternalSheller', shell.class.name
  end

end
