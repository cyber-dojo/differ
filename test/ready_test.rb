# frozen_string_literal: true
require_relative 'differ_test_base'
require 'ostruct'

class ReadyTest < DifferTestBase

  def self.id58_prefix
    '0B2'
  end

  # - - - - - - - - - - - - - - - - -

  test '602',
  %w( its ready ) do
    h = differ.ready?
    assert true?(h['ready?'])
  end

  # - - - - - - - - - - - - - - - - -

  test '603', %w(
  |when model http-proxy is not ready
  |then ready? is false
  ) do
    externals.instance_exec { @model=STUB_READY_FALSE }
    h = differ.ready?
    assert false?(h['ready?'])
  end

  private

  STUB_READY_FALSE = OpenStruct.new(:ready? => false)

  def true?(b)
    b.instance_of?(TrueClass)
  end

  def false?(b)
    b.instance_of?(FalseClass)
  end

end
