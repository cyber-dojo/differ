require_relative 'string_cleaner'

class ExternalSheller

  def cd_exec(path, *commands)
    # the [[ -d ]] is to avoid spurious [cd path] failure
    # output when the tests are running
    output, exit_status = exec(["[[ -d #{path} ]]", "cd #{path}"] + commands)
    [output, exit_status]
  end

  def exec(*commands)
    output = `#{commands.join(' && ')}`
    exit_status = $?.exitstatus
    [cleaned(output), exit_status]
  end

  private

  include StringCleaner

end
