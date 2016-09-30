
require_relative './lib_test_base'

class ExternalDiskWriterTest < LibTestBase

  def self.hex(suffix)
    'FDF' + suffix
  end

  class App; include Externals; end

  def disk; App.new.disk; end

  test 'D4C',
  'what gets written gets read back' do
    Dir.mktmpdir('file_writer') do |tmp_dir|
      pathed_filename = tmp_dir + '/limerick.txt'
      content = 'the boy stood on the burning deck'
      disk.write(pathed_filename, content)
      File.open(pathed_filename, 'r') { |fd| assert_equal content, fd.read }
    end
  end

end
