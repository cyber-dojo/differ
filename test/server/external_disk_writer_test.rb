require_relative 'differ_test_base'

class ExternalDiskWriterTest < DifferTestBase

  test 'FDFD4C', %w(
  | what gets written gets read back
  ) do
    Dir.mktmpdir('file_writer') do |tmp_dir|
      pathed_filename = "#{tmp_dir}/limerick.txt"
      content = 'the boy stood on the burning deck'
      disk.write(pathed_filename, content)
      File.open(pathed_filename, 'r') { |fd| assert_equal content, fd.read }
    end
  end

end
