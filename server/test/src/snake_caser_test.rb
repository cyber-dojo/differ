
require_relative './differ_test_base'
require_relative '../../src/snake_caser'

class SnakeCaserTest < DifferTestBase

  def self.hex(suffix)
    '59B' + suffix
  end

  test 'A70',
  'hissssss' do
    assert_equal 'external_stdout_logger', 'ExternalStdoutLogger'.snake_cased
    assert_equal 'external_sheller'      , 'ExternalSheller'     .snake_cased
    assert_equal 'external_gitter'       , 'ExternalGitter'      .snake_cased
    assert_equal 'external_file_writer'  , 'ExternalFileWriter'  .snake_cased
  end

end
