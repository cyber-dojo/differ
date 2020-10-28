# frozen_string_literal: true

class Prober

  def initialize(externals)
    @externals = externals
  end

  def sha # identity
    { 'sha' => ENV['SHA'] }
  end

  def healthy? # Dockerfile HEALTHCHECK
    { 'healthy?' => prepared? }
  end

  def alive? # k8s
    { 'alive?' => true }
  end

  def ready? # k8s
    { 'ready?' => prepared? }
  end

  private

  def prepared?
    @externals.model.ready?
  end

end
