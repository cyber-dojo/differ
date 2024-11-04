# frozen_string_literal: true

require 'simplecov'
require_relative 'simplecov_formatter_json'

SimpleCov.start do
  enable_coverage :branch
  filters.clear
  add_filter('test/lib/id58_test_base.rb')
  coverage_dir(ENV.fetch('COVERAGE_ROOT', nil))
  # add_group('debug') { |src| puts src.filename; false }
  test_tab = ENV.fetch('COVERAGE_TEST_TAB_NAME')
  code_tab = ENV.fetch('COVERAGE_CODE_TAB_NAME')
  test_re = %r{^/differ/test}
  add_group(test_tab) { |src| src.filename =~ test_re }
  add_group(code_tab) { |src| src.filename !~ test_re }
end

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
