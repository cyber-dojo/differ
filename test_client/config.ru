require 'rack'
require_relative 'src/demo'
require_relative 'src/differ_service'
require_relative 'src/externals'

externals = Externals.new
differ = DifferService.new(externals)
run Demo.new(differ)
