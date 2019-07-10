require_relative 'external_disk_writer'
require_relative 'external_gitter'
require_relative 'external_sheller'
require_relative 'external_stdout_logger'

class Externals

  def disk
    @disk ||= ExternalDiskWriter.new
  end
  def disk=(doppel)
    @disk = doppel
  end

  def git
    @git ||= ExternalGitter.new(self)
  end

  def log
    @log ||= ExternalStdoutLogger.new
  end
  def log=(doppel)
    @log = doppel
  end

  def shell
    @shell ||= ExternalSheller.new(self)
  end
  def shell=(doppel)
    @shell = doppel
  end

end
