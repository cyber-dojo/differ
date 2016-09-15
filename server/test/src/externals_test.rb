#!/bin/sh ../shebang_run.sh

require_relative './lib_test_base'

class ExternalsTest < LibTestBase

  include Externals

  test '7A9920',
  'default file is ExternalFileWriter' do
    assert_equal 'ExternalFileWriter', file.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test 'A40C8F',
  'default git is ExternalGitter' do
    assert_equal 'ExternalGitter', git.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '05A3EC',
  'default log is ExternalStdoutLogger' do
    assert_equal 'ExternalStdoutLogger', log.class.name
  end

  # - - - - - - - - - - - - - - - - -

  test '6591B1',
  'default shell is ExternalSheller' do
    assert_equal 'ExternalSheller', shell.class.name
  end

end
