#!/bin/sh ../test_wrapper.sh

require_relative './lib_test_base'

class ExternalFileWriterTest < LibTestBase

  test 'FDFD4C',
  'what gets written can be read back' do
    file = ExternalFileWriter.new(nil)
    Dir.mktmpdir('file_writer') do |tmp_dir|
      pathed_filename = tmp_dir + '/limerick.txt'
      content = 'the boy stood on the burning deck'
      file.write(pathed_filename, content)
      File.open(pathed_filename, 'r') { |fd| assert_equal content, fd.read }
    end
  end

end
