$stdout.sync = true
$stderr.sync = true

require_relative 'src/client'
require_relative 'src/differ_service'
require_relative 'src/externals'
require 'rack'

externals = Externals.new
differ = DifferService.new(externals)
run Client.new(differ)
