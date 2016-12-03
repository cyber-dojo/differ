require 'simplecov'

cov_root = File.expand_path('..', File.dirname(__FILE__))

SimpleCov.start do
  add_filter 'src/demo.rb'
  add_group 'src',      "#{cov_root}/src"
  add_group 'test/src', "#{cov_root}/test/src"
end

SimpleCov.root cov_root
SimpleCov.coverage_dir '/tmp/coverage'