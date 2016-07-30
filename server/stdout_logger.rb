
class StdoutLogger

  def initialize(_parent)
  end

  def <<(message)
    p message
  end

end
