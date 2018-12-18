require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

require_relative './src/rack_dispatcher'

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run RackDispatcher.new
