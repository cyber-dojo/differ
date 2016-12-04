
require_relative './external_disk_writer'
require_relative './external_gitter'
require_relative './external_sheller'
require_relative './external_stdout_logger'

module Externals # mix-in

  def shell; @shell ||= ExternalSheller.new(self);      end
  def disk ;  @disk ||= ExternalDiskWriter.new(self);   end
  def git  ;   @git ||= ExternalGitter.new(self);       end
  def log  ;   @log ||= ExternalStdoutLogger.new(self); end

end
