require 'simplecov'

SimpleCov.start do

  add_group('debug') { |src|
    #p src.filename
    false
  }

  add_group 'src',      '/usr/app/src'
  add_group 'test/src', '/usr/app/test/src'
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
SimpleCov.coverage_dir '/tmp/coverage'