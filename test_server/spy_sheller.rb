
class SpySheller

  def initialize
    @spied = []
  end

  attr_reader :spied

  def cd_exec(path, *commands)
    spied << [path]+[*commands]
  end

end
