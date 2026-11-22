require 'simplecov'
require 'path_coverage'
require_relative 'simplecov_formatter_json'

APP_DIR = ENV.fetch('APP_DIR')
CODE_TAB = ENV.fetch('COVERAGE_CODE_TAB_NAME')
TEST_TAB = ENV.fetch('COVERAGE_TEST_TAB_NAME')
CODE_GLOB = 'source/**/*.rb'
TEST_GLOB = 'test/**/*.rb'

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  coverage_dir(ENV.fetch('COVERAGE_ROOT'))
  root(APP_DIR)
  cover(CODE_GLOB)
  cover { |file| file.project_filename.start_with?('test/') }
  skip('test/lib/id58_test_base.rb')
  skip('source/config/')

  # group('debug') { |path| puts path.filename; false }
  group(TEST_TAB) { |path| path.filename.start_with?("#{APP_DIR}/test/") }
  group(CODE_TAB) { |path| path.filename.start_with?("#{APP_DIR}/source/") }
end

# Covers the same files as SimpleCov above, and prints each path no test took.
# A method with more than 8 paths fails; run.sh checks the report this writes.
PathCoverage.start do
  root(APP_DIR)
  coverage_dir("#{ENV.fetch('COVERAGE_ROOT')}/paths")
  report(:gaps, :summary)
  max_paths(8)
  cover(CODE_GLOB)
  cover(TEST_GLOB)
  skip('source/config/**/*.rb')
  # Test tooling, the id58 base and the reporters and metrics checks, which
  # run around the tests, not as them.
  skip('test/lib/**/*.rb')
  group(CODE_TAB, CODE_GLOB)
  group(TEST_TAB, TEST_GLOB)
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
