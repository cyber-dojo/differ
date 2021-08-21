$stdout.sync = true
$stderr.sync = true

require_relative '../app/client'
require_relative '../app/differ'
require 'rack'

run Client.new(External::Differ.new)
