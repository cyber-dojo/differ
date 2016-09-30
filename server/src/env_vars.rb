
require_relative './snake_case'

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
