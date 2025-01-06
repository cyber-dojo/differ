# frozen_string_literal: true

require 'json'
require 'minitest/reporters'

class Minitest::Reporters::SlimJsonReporter < Minitest::Reporters::BaseReporter
  def report
    super
    filename = "#{ENV.fetch('COVERAGE_ROOT')}/test_metrics.json"
    metrics = {
      total_time: total_time.round(2),
      assertion_count: assertions,
      test_count: count,
      failure_count: failures,
      error_count: errors,
      skip_count: skips,
      variables: {
        min: {
          test_count: 73,
        },
        max: {
          total_time: 50,
        }
      }
    }
    File.write(filename, JSON.pretty_generate(metrics))
  end
end
