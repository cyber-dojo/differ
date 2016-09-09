class String
  def snake_case
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    downcase
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - -

{
  'LOG'   => 'ExternalStdoutLogger',
  'SHELL' => 'ExternalSheller',
  'GIT'   => 'ExternalGitter',
  'FILE'  => 'ExternalFileWriter'
}.each do |service,name|
  ENV['DIFFER_CLASS_'+service] = name
  require_relative './' + name.snake_case
end

%w(name_of_caller unslashed).each { |file| require_relative './' + file }

# - - - - - - - - - - - - - - - - - - - - - - - -

module Externals # mix-in

  module_function

  def log;   @log   ||= external_object; end
  def shell; @shell ||= external_object; end
  def git;   @git   ||= external_object; end
  def file;  @file  ||= external_object; end

  private

  def external_object
    name = 'DIFFER_CLASS_' + name_of(caller).upcase
    var = unslashed(ENV[name] || fail("ENV[#{name}] not set"))
    Object.const_get(var).new(self)
  end

  include NameOfCaller
  include Unslashed

end
