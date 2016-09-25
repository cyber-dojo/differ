
require_relative './snake_case'

# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/external_helper.rb

def env_name(suffix)
  'DIFFER_CLASS_' + suffix.upcase
end

def env_map
  {
    env_name('disk')  => 'ExternalDiskWriter',
    env_name('git')   => 'ExternalGitter',
    env_name('log')   => 'ExternalStdoutLogger',
    env_name('shell') => 'ExternalSheller'
  }
end

env_map.each do |key,name|
  ENV[key] = name
  require_relative "./#{name.snake_case}"
end

# - - - - - - - - - - - - - - - - - - - - - - - -

require_relative './name_of_caller'

module Externals # mix-in

  def disk ; @disk  ||= external; end
  def git  ; @git   ||= external; end
  def log  ; @log   ||= external; end
  def shell; @shell ||= external; end

  private

  def external
    name = env_name(name_of(caller).upcase)
    var = ENV[name] || fail("ENV[#{name}] not set")
    Object.const_get(var).new(self)
  end

  include NameOfCaller

end
