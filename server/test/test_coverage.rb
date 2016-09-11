require 'simplecov'

SimpleCov.start do
  filters.clear
  add_group 'lib', 'lib'
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
