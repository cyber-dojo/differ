$stdout.sync = true
$stderr.sync = true

unless ENV['NO_PROMETHEUS']
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'code/externals'
require_relative 'code/differ'
require_relative 'code/rack_dispatcher'
require 'rack'
externals = Externals.new
differ = Differ.new(externals)
dispatcher = RackDispatcher.new(differ, Rack::Request)
run dispatcher
