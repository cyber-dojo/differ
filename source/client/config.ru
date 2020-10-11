$stdout.sync = true
$stderr.sync = true

require_relative 'app/client'
require_relative 'app/differ_service'
require_relative 'app/externals'
require 'rack'

externals = Externals.new
differ = DifferService.new(externals)
run Client.new(differ)
