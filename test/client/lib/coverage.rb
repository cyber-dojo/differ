# frozen_string_literal: true

require 'simplecov'
require_relative 'simplecov_formatter_json'

APP_DIR = ENV.fetch('APP_DIR')

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  add_filter('test/lib/id58_test_base.rb')
  coverage_dir(ENV.fetch('COVERAGE_ROOT', nil))
  root(APP_DIR)

  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME')
  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME')
  # add_group('debug') { |the| puts the.filename; false }
  add_group(test_tab) { |the| the.filename.start_with?("#{APP_DIR}/test/") }
  add_group(code_tab) { |the| the.filename.start_with?("#{APP_DIR}/source/") }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
