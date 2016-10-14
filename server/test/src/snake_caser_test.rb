
require_relative './lib_test_base'

class SnakeCaserTest < LibTestBase

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
