require_relative 'utf8_clean'
require 'open3'

class ExternalSheller

  def assert_cd_exec(path, *commands)
    assert_exec(["cd #{path}"] + commands)
  end

  def assert_exec(*commands)
    stdout,stderr,r = Open3.capture3('sh -c ' + quoted(commands.join(' && ')))
    stdout = Utf8::clean(stdout)
    stderr = Utf8::clean(stderr)
    exit_status = r.exitstatus
    unless exit_status === 0 && stderr === ''
      diagnostic = {
        stdout:stdout,
        stderr:stderr,
        exit_status:exit_status
      }
      raise diagnostic.to_json
    end
    stdout
  end

  private

  def quoted(s)
    '"' + s + '"'
  end

end
