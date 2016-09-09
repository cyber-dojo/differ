
$differ_env_root = 'DIFFER_CLASS_'

require_relative './snake_case'

# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can reset these in the setups

{
  'LOG'   => 'ExternalStdoutLogger',
  'SHELL' => 'ExternalSheller',
  'GIT'   => 'ExternalGitter',
  'FILE'  => 'ExternalFileWriter'
}.each do |service,name|
  ENV[$differ_env_root + service] = name
  require_relative "./#{name.snake_case}"
end

# - - - - - - - - - - - - - - - - - - - - - - - -

require_relative './name_of_caller'
require_relative './unslashed'

module Externals # mix-in

  module_function

  def log  ; @log   ||= external_object; end
  def shell; @shell ||= external_object; end
  def git  ; @git   ||= external_object; end
  def file ; @file  ||= external_object; end

  private

  def external_object
    name = $differ_env_root + name_of(caller).upcase
    var = unslashed(ENV[name] || fail("ENV[#{name}] not set"))
    Object.const_get(var).new(self)
  end

  include NameOfCaller
  include Unslashed

end
