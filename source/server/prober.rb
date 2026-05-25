class Prober
  def initialize(_externals)
  end

  def alive
    true
  end

  def ready
    true
  end

  def sha
    ENV.fetch('COMMIT_SHA', nil)
  end
end
