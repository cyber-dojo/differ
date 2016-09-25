
require_relative './lib_test_base'
require_relative './spy_logger'


class ExternalShellerTest < LibTestBase

  def self.hex(suffix)
    'C89' + suffix
  end

  class App; include Externals; end

  def setup
    super
    ENV[env_name('log')] = 'SpyLogger'
    @app = App.new
  end

  def shell; @app.shell; end
  def log  ; @app.log  ; end

  # - - - - - - - - - - - - - - - - -
  # exec()
  # - - - - - - - - - - - - - - - - -

  test 'DBB',
  'when exec() succeeds:' +
  '(1)output is captured,' +
  '(2)exit-status is success,' +
  '(3)log records success' do
    shell_exec('echo -n Hello')
    assert_output 'Hello'
    assert_exit_status success
    assert_log [
      'COMMAND:echo -n Hello',
      'OUTPUT:Hello',
      'EXITED:0'
    ]
  end

  # - - - - - - - - - - - - - - - - -

  test 'AF6',
  'when exec() fails:' +
  '(0)exception is raised,' +
  '(1)output is captured,' +
  '(2)exit-status is not success,' +
  '(3)log records failure' do
    assert_raises { shell_exec('zzzz') }
    assert_log [
      'COMMAND:zzzz',
      'RAISED-CLASS:Errno::ENOENT',
      'RAISED-TO_S:No such file or directory - zzzz'
    ]
  end

  # - - - - - - - - - - - - - - - - -
  # cd_exec()
  # - - - - - - - - - - - - - - - - -

  test 'ACD',
  "cd_exec(): when the cd fails:" +
  '(0)the command is not executed,' +
  '(1)output is empty,' +
  '(2)exit-status is not success,' +
  '(3)log records no-output and exit-status' do
    shell_cd_exec('zzzz', 'echo -n Hello')
    assert_output ''
    assert_exit_status  1
    assert_log [
      'COMMAND:[[ -d zzzz ]] && cd zzzz && echo -n Hello',
      'NO-OUTPUT:',
      'EXITED:1'
    ]
  end

  # - - - - - - - - - - - - - - - - -

  test '0B8',
  'cd_exec(): when the cd succeeds and the exec succeeds:' +
  '(0)output is captured,'+
  '(1)exit-status is success,' +
  '(2)log records output and exit-status' do
    shell_cd_exec('.', 'echo -n Hello')
    assert_output 'Hello'
    assert_exit_status success
    assert_log [
      'COMMAND:[[ -d . ]] && cd . && echo -n Hello',
      'OUTPUT:Hello',
      'EXITED:0'
    ]
  end

  # - - - - - - - - - - - - - - - - -

  test '995',
  'cd_exec(): when cd succeeds and the exec fails:' +
  '(0) output is captured and exit-status is not success' do
    shell_cd_exec('.', 'zzzz 2> /dev/null')
    assert_output ''
    assert_exit_status 127
    assert_log [
      'COMMAND:[[ -d . ]] && cd . && zzzz 2> /dev/null',
      'NO-OUTPUT:',
      'EXITED:127'
    ]
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

  def assert_log(expected)
    line = '-' * 40
    assert_equal [line] + expected, log.spied
  end

  def success
    0
  end

end
