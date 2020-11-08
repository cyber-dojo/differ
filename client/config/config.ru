$stdout.sync = true
$stderr.sync = true

require_relative '../app/client'
require_relative '../app/differ_service'
require 'rack'

run Client.new(External::DifferService.new)
