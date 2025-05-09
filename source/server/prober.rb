# frozen_string_literal: true

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
    ENV.fetch('SHA', nil)
  end
end
