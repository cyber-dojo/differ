require 'simplecov'

SimpleCov.start do
  # exclude test_hex_id_helpers.rb because it contains
  # ObjectSpace.define_finalizer(self, proc { ... }
  # to detect any unfound hex-id args
  add_filter '/usr/app/test/hex_id_helpers.rb'

  add_group 'lib',      '/usr/app/lib'
  add_group 'test/lib', '/usr/app/test'
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
