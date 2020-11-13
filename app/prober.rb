# frozen_string_literal: true

class Prober

  def initialize(externals)
    @externals = externals
  end

  def sha # identity
    ENV['SHA']
  end

  def healthy? # Dockerfile HEALTHCHECK
    prepared?
  end

  def alive? # k8s
    true
  end

  def ready? # k8s
    prepared?
  end

  private

  def prepared?
    @externals.model.ready?
  end

end
