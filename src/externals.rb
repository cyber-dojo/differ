require_relative 'external_disk_writer'
require_relative 'external_gitter'
require_relative 'external_sheller'

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

  def shell
    @shell ||= ExternalSheller.new
  end
  def shell=(doppel)
    @shell = doppel
  end

end
