
%w(name_of_caller unslashed file_writer host_sheller host_gitter stdout_logger
).each { |file|
  require_relative './' + file
}

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
