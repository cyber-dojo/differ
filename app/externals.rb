require_relative 'external/disk_writer'
require_relative 'external/gitter'
require_relative 'external/http'
require_relative 'external/saver'
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

  # - - - - - - - - - - - - - - - - -

  def saver
    @saver ||= External::Saver.new(self)
  end

  def saver_http
    @saver_http ||= External::Http.new
  end
end
