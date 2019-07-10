require_relative 'string_cleaner'
require 'open3'

class ExternalSheller

  def assert_cd_exec(path, *commands)
    assert_exec(["cd #{path}"] + commands)
  end

  def assert_exec(*commands)
    stdout,stderr,r = Open3.capture3('sh -c ' + quoted(commands.join(' && ')))
    stdout = cleaned(stdout)
    stderr = cleaned(stderr)
    exit_status = r.exitstatus
    unless exit_status === 0 && stderr === ''
      info = {
        "stdout" => stdout,
        "stderr" => stderr,
        "exit_status" => exit_status
      }
      raise info.to_json
    end
    stdout
  end

  private

  include StringCleaner

  def quoted(s)
    '"' + s + '"'
  end

end
