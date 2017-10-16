require_relative 'string_cleaner'

class ExternalSheller

  def initialize(parent)
    @log = parent.log
  end

  def cd_exec(path, *commands)
    # the [[ -d ]] is to avoid spurious [cd path] failure
    # output when the tests are running
    output, exit_status = exec(["[[ -d #{path} ]]", "cd #{path}"] + commands)
    [output, exit_status]
  end

  def exec(*commands)
    command = commands.join(' && ')
    log << '-'*40
    log << "COMMAND:#{command}"

    begin
      output = `#{command}`
    rescue Exception => e
      log << "RAISED-CLASS:#{e.class.name}"
      log << "RAISED-TO_S:#{e.to_s}"
      raise e
    end

    exit_status = $?.exitstatus
    log << "NO-OUTPUT:" if output == ''
    log << "OUTPUT:#{output}" if output != ''
    log << "EXITED:#{exit_status}"
    [cleaned(output), exit_status]
  end

  private

  attr_reader :log # external

  include StringCleaner

end
