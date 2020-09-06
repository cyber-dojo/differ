$stdout.sync = true
$stderr.sync = true

require 'rack'
use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }

if ENV['CYBER_DOJO_PROMETHEUS'] === 'true'
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'code/externals'
require_relative 'code/differ'
require_relative 'code/rack_dispatcher'
externals = Externals.new
differ = Differ.new(externals)
dispatcher = RackDispatcher.new(differ, Rack::Request)
run dispatcher
