
class ExternalStdoutLogger

  def initialize(_parent)
  end

  def <<(message)
    p message
  end

end
