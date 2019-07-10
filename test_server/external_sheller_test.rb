require_relative 'differ_test_base'

class ExternalShellerTest < DifferTestBase

  def self.hex_prefix
    'C89'
  end

  # - - - - - - - - - - - - - - - - -

  test 'DBB',
  'exec(*commands) returns stdout when the commands all succeed' do
    assert_equal 'Hello', shell.exec('echo -n Hello')
  end

  test '0B8',
  'cd_exec(path,*commands) returns stdout when the cd and the commands succeeds' do
    assert_equal 'Hello', shell.cd_exec('.', 'echo -n Hello')
  end

  # - - - - - - - - - - - - - - - - -

  test 'AF6',
  'exec(*commands) raises when a command fails' do
    error = assert_raises { shell.exec('zzzz') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert_equal "sh: zzzz: not found\n", json['stderr']
    assert_equal 127,  json['exit_status']
  end

  test 'ACD',
  'cd_exec(path,*commands) raises when the cd fails' do
    error = assert_raises { shell.cd_exec('zzzz', 'echo -n Hello') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert_equal "sh: cd: line 1: can't cd to zzzz: No such file or directory\n", json['stderr']
    assert_equal 2,  json['exit_status']
  end

  test '995',
  'cd_exec(path,*commands) raises when a command fails' do
    error = assert_raises { shell.cd_exec('.', 'zzzz') }
    json = JSON.parse(error.message)
    assert_equal '', json['stdout']
    assert_equal "sh: zzzz: not found\n", json['stderr']
    assert_equal 127,  json['exit_status']
  end

end
