require_relative 'external_disk_writer'
require_relative 'external_gitter'
require_relative 'external_sheller'
require_relative 'external_stdout_logger'

class Externals

  def disk
    @disk ||= ExternalDiskWriter.new(self)
  end
  def disk=(obj)
    @disk = obj
  end

  def git
    @git ||= ExternalGitter.new(self)
  end

  def log
    @log ||= ExternalStdoutLogger.new(self)
  end
  def log=(obj)
    @log = obj
  end

  def shell
    @shell ||= ExternalSheller.new(self)
  end
  def shell=(obj)
    @shell = obj
  end

end
