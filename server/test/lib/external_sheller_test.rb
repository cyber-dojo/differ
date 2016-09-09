#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'
require_relative './spy_logger'

class ExternalShellerTest < LibTestBase

  def setup
    ENV['DIFFER_CLASS_LOG'] = 'SpyLogger'
    super
    @differ = Differ.new(nil, nil)
  end

  def shell; @differ.shell; end
  def log  ; @differ.log  ; end

  # - - - - - - - - - - - - - - - - -

  test '6591B1',
  'default shell is ExternalSheller' do
    assert_equal 'ExternalSheller', shell.class.name
    assert_equal [], log.spied
  end

  # - - - - - - - - - - - - - - - - -
  # exec()
  # - - - - - - - - - - - - - - - - -

  test 'C89DBB',
  'when exec() succeeds:' +
  '(1)output is captured,' +
  '(2)exit-status is success,' +
  '(3)log records success' do
    output, exit_status = shell.exec('echo -n Hello')
    assert_equal 'Hello', output
    assert_equal success, exit_status
    assert_log_equal [
      'COMMAND:echo -n Hello',
      'OUTPUT:Hello',
      'EXITED:0'
    ]
  end

  test '3C3AF6',
  'when exec() fails:' +
  '(0)exception is raised,' +
  '(1)output is captured,' +
  '(2)exit-status is not success,' +
  '(3)log records failure' do
    assert_raises { shell.exec('zzzz') }
    assert_log_equal [
      'COMMAND:zzzz',
      'RAISED-CLASS:Errno::ENOENT',
      'RAISED-TO_S:No such file or directory - zzzz'
    ]
  end

  # - - - - - - - - - - - - - - - - -
  # cd_exec()
  # - - - - - - - - - - - - - - - - -

  test '565ACD',
  "cd_exec(): when the cd fails:" +
  '(0)the command is not executed,' +
  '(1)output is empty,' +
  '(2)exit-status is not success,' +
  '(3)log records no-output and exit-status' do
    output, exit_status = shell.cd_exec('zzzz', 'echo -n Hello')
    assert_equal '', output
    refute_equal success, exit_status
    assert_log_equal [
      'COMMAND:[[ -d zzzz ]] && cd zzzz && echo -n Hello',
      'NO-OUTPUT:',
      'EXITED:1'
    ]
  end

  test 'E180B8',
  'cd_exec(): when the cd succeeds and the exec succeeds:' +
  '(0)output is captured,'+
  '(1)exit-status is success,' +
  '(2)log records output and exit-status' do
    output, exit_status = shell.cd_exec('.', 'echo -n Hello')
    assert_equal 'Hello', output
    assert_equal success, exit_status
    assert_log_equal [
      'COMMAND:[[ -d . ]] && cd . && echo -n Hello',
      'OUTPUT:Hello',
      'EXITED:0'
    ]
  end

  test '373995',
  'cd_exec(): when cd succeeds and the exec fails:' +
  '(0) output is captured and exit-status is not success' do
    output, exit_status = shell.cd_exec('.', 'zzzz 2> /dev/null')
    assert_equal '', output
    refute_equal success, exit_status
    assert_log_equal [
      'COMMAND:[[ -d . ]] && cd . && zzzz 2> /dev/null',
      'NO-OUTPUT:',
      'EXITED:127'
    ]
  end

  # - - - - - - - - - - - - - - - - -

  def assert_log_equal(expected)
    line = '-'*40
    assert_equal [line]+expected, log.spied
  end

  def success
    0
  end

end
