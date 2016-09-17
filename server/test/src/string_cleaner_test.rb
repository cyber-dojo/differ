
require_relative './lib_test_base'

class StringCleanerTest < LibTestBase

  def self.hex(suffix)
    '3D9' + suffix
  end

  include StringCleaner

  test '7FE',
  'cleaned string is not phased by invalid encodings' do
    bad_str = (100..1000).to_a.pack('c*').force_encoding('utf-8')
    refute bad_str.valid_encoding?
    good_str = cleaned(bad_str)
    assert good_str.valid_encoding?
  end

end
