# frozen_string_literal: true

class Prober

  def initialize(externals)
    @externals = externals
  end

  def sha
    { 'sha' => ENV['SHA'] }
  end

  def alive?
    { 'alive?' => true }
  end

  def ready?
    { 'ready?' => model.ready? }
  end

  private

  def model
    @externals.model
  end

end
