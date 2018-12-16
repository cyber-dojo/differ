
class SpySheller

  def initialize(_)
    @spied = []
  end

  attr_reader :spied

  def cd_exec(path, *commands)
    spied << [path]+[*commands]
  end

end
