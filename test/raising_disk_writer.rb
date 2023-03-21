class RaisingDiskWriter
  attr_reader :pathed_filename

  def write(pathed_filename, _content)
    @pathed_filename = pathed_filename
    raise 'raising'
  end
end
