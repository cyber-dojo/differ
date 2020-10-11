
class SpySheller

  def initialize
    @spied = []
  end

  attr_reader :spied

  def assert_cd_exec(path, *commands)
    spied << [path]+[*commands]
  end

end
