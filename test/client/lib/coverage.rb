require 'simplecov'
require_relative 'simplecov_formatter_json'

APP_DIR = ENV.fetch('APP_DIR')

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  coverage_dir(ENV.fetch('COVERAGE_ROOT'))
  root(APP_DIR)
  cover('source/**/*.rb')
  cover { |file| file.project_filename.start_with?('test/') }
  skip('test/lib/id58_test_base.rb')
  skip('source/config/')
  skip('source/html_demo.rb')

  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME')
  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME')
  # group('debug') { |path| puts path.filename; false }
  group(test_tab) { |path| path.filename.start_with?("#{APP_DIR}/test/") }
  group(code_tab) { |path| path.filename.start_with?("#{APP_DIR}/source/") }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  CoverageMetricsFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
