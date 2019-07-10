
class ExternalDiskWriter

  def initialize(_externals)
  end

  def write(pathed_filename, content)
    File.open(pathed_filename, 'w') { |fd| fd.write(content) }
  end

end
