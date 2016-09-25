
require_relative './lib_test_base'
require_relative './null_logger'
require_relative './raising_disk_writer'

class ExceptionSafetyTest < LibTestBase

  include Externals

  def self.hex(suffix)
    '968' + suffix
  end

  test 'B9F',
  'tmp dir is deleted if exception is raised' do
    ENV[env_name('log')]  = 'NullLogger'
    ENV[env_name('disk')] = 'RaisingDiskWriter'
    was_files = { 'diamond.h' => 'a' } # ensure something to write
    now_files = {}
    differ = GitDiffer.new(self)
    raised = assert_raises(RuntimeError) { differ.diff(was_files, now_files) }
    assert_equal 'raising', raised.message
    dir = File.dirname(differ.disk.pathed_filename)
    refute Dir.exists?(dir)
  end

end
