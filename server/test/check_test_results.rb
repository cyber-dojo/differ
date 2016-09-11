
def f2(s)
  result = ("%.2f" % s).to_s
  result += '0' if result.end_with?('.0')
  result
end

def get_test_log_stats
  test_log=`cat #{ARGV[0]}`
  # guard against invalid byte sequence
  test_log = test_log.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
  test_log = test_log.encode('UTF-8', 'UTF-16')

  number = '[\.|\d]+'

  h = {}
  finished_pattern = "Finished in (#{number})s, (#{number}) runs/s, (#{number}) assertions/s"
  m = test_log.match(Regexp.new(finished_pattern))
  h[:time]               = f2(m[1])
  h[:tests_per_sec]      = m[2].to_i
  h[:assertions_per_sec] = m[3].to_i

  summary_pattern = %w(runs assertions failures errors skips).map{ |s| "(#{number}) #{s}" }.join(', ')
  m = test_log.match(Regexp.new(summary_pattern))
  h[:test_count]      = m[1].to_i
  h[:assertion_count] = m[2].to_i
  h[:failure_count]   = m[3].to_i
  h[:error_count]     = m[4].to_i
  h[:skip_count]      = m[5].to_i

  coverage_pattern = "Coverage report generated for MiniTest to /usr/app/coverage. #{number} / #{number} LOC \\((#{number})%\\)"
  m = test_log.match(Regexp.new(coverage_pattern))
  h[:coverage] = f2(m[1])
  h
end

# - - - - - - - - - - - - - - - - - - - - - - -

stats = get_test_log_stats
done =
  [
     [ "coverage == 100%", stats[:coverage] == '100.00' ],
     [ "total failures == 0", stats[:failure_count] <= 0 ],
     [ "total errors == 0", stats[:error_count] == 0 ],
     [ "total skips == 0", stats[:skip_count] == 0],
     [ "total secs < 1", stats[:time].to_f < 1 ],
     [ "total assertions per sec > 500", stats[:assertions_per_sec] > 500 ]
  ]

yes,no = done.partition { |criteria| criteria[1] }

unless yes.empty?
  puts "DONE"
  yes.each { |criteria| puts criteria[0] }
end

unless no.empty?
  print "\n"
  puts "!DONE"
  no.each { |criteria| puts criteria[0] }
  exit 1
else
  exit 0
end

