$stdout.sync = true
$stderr.sync = true

require_relative 'code/client'
require_relative 'code/differ_service'
require_relative 'code/externals'
require 'rack'

externals = Externals.new
differ = DifferService.new(externals)
run Client.new(differ)
