require 'minitest/reporters'

module SlowTestsTimings
  TIMINGS = {}
  LOCK = Mutex.new
end

class Minitest::Reporters::SlowTestsReporter < Minitest::Reporters::BaseReporter
  def report
    # Prints the 5 slowest tests by duration after the full test run.
    super
    sorted = SlowTestsTimings::TIMINGS.sort_by { |_name, secs| -secs }.first(5)
    puts
    puts 'Slowest tests are...'
    sorted.each do |(name, secs)|
      puts format('%3.4f %-72s', secs, name)
    end
    puts
  end
end
