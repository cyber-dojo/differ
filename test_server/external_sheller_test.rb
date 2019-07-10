require_relative 'differ_test_base'
#require_relative 'spy_logger'

class ExternalShellerTest < DifferTestBase

  def self.hex_prefix
    'C89'
  end

  # - - - - - - - - - - - - - - - - -
  # exec()
  # - - - - - - - - - - - - - - - - -

  test 'DBB',
  'when exec() succeeds:' +
  '(0)exception is not raised,' +
  '(1)output is captured,' +
  '(2)exit-status is success' do
    shell_exec('echo -n Hello')
    assert_output 'Hello'
    assert_exit_status success
  end

  # - - - - - - - - - - - - - - - - -

  test 'AF6',
  'when exec() fails:' +
  '(0)exception is raised,' +
  '(1)output is captured,' +
  '(2)exit-status is not success' do
    error = assert_raises(Errno::ENOENT) { shell_exec('zzzz') }
    assert_equal 'No such file or directory - zzzz', error.message
  end

  # - - - - - - - - - - - - - - - - -
  # cd_exec()
  # - - - - - - - - - - - - - - - - -

  test 'ACD',
  "cd_exec(): when the cd fails:" +
  '(0)the command is not executed,' +
  '(1)output is empty,' +
  '(2)exit-status is not success' do
    shell_cd_exec('zzzz', 'echo -n Hello')
    assert_output ''
    assert_exit_status 1
  end

  # - - - - - - - - - - - - - - - - -

  test '0B8',
  'cd_exec(): when the cd succeeds and the exec succeeds:' +
  '(0)output is captured,'+
  '(1)exit-status is success' do
    shell_cd_exec('.', 'echo -n Hello')
    assert_output 'Hello'
    assert_exit_status success
  end

  # - - - - - - - - - - - - - - - - -

  test '995',
  'cd_exec(): when cd succeeds and the exec fails:' +
  '(0)output is captured,' +
  '(1)exit-status is not success' do
    shell_cd_exec('.', 'zzzz 2> /dev/null')
    assert_output ''
    assert_exit_status 127
  end

  # - - - - - - - - - - - - - - - - -

  def shell_exec(command)
    @output, @exit_status = shell.exec(command)
  end

  def shell_cd_exec(dir, command)
    @output, @exit_status = shell.cd_exec(dir, command)
  end

  def assert_output(expected)
    assert_equal expected, @output
  end

  def assert_exit_status(expected)
    assert_equal expected, @exit_status
  end

  def success
    0
  end

end
