
require_relative './snake_case'

# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/external_helper.rb

def env_root(suffix = '')
  'DIFFER_CLASS_' + suffix
end

def env_map
  {
    env_root('FILE')  => 'ExternalFileWriter',
    env_root('GIT')   => 'ExternalGitter',
    env_root('LOG')   => 'ExternalStdoutLogger',
    env_root('SHELL') => 'ExternalSheller'
  }
end

env_map.each do |key,name|
  ENV[key] = name
  require_relative "./#{name.snake_case}"
end

# - - - - - - - - - - - - - - - - - - - - - - - -

require_relative './name_of_caller'

module Externals # mix-in

  def file ; @file  ||= external; end
  def git  ; @git   ||= external; end
  def log  ; @log   ||= external; end
  def shell; @shell ||= external; end

  private

  def external
    name = env_root(name_of(caller).upcase)
    var = ENV[name] || fail("ENV[#{name}] not set")
    Object.const_get(var).new(self)
  end

  include NameOfCaller

end
