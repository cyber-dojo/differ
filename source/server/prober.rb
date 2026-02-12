class Prober
  def initialize(externals)
    @externals = externals
  end

  def alive
    true
  end

  def ready
    @externals.saver.ready?
  end

  def sha
    ENV.fetch('COMMIT_SHA', nil)
  end
end
