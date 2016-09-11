require 'simplecov'

SimpleCov.start do
  filters.clear
  add_group 'lib', '/usr/app/lib'
  add_group('test/lib') { |src|
    # exclude test_hex_id_helpers.rb because it contains
    # ObjectSpace.define_finalizer(self, proc { ... }
    # to detect any unfound hex-id args
    src.filename.start_with?('/usr/app/test/') &&
    src.filename != '/usr/app/test/hex_id_helpers.rb'
  }
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
