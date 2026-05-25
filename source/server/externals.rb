require_relative 'external/disk_writer'
require_relative 'external/gitter'
require_relative 'external/sheller'

class Externals
  def disk
    @disk ||= External::DiskWriter.new
  end

  def git
    @git ||= External::Gitter.new(self)
  end

  def shell
    @shell ||= External::Sheller.new
  end
end
