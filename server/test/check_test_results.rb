
def number
  '[\.|\d]+'
end

def f2(s)
  result = ("%.2f" % s).to_s
  result += '0' if result.end_with?('.0')
  result
end

def get_index_stats(flat, name)
  html = `cat #{ARGV[1]}`
  # guard against invalid byte sequence
  html = html.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
  html = html.encode('UTF-8', 'UTF-16')

  pattern = /<div class=\"file_list_container\" id=\"#{flat}\">
  \s*<h2>\s*<span class=\"group_name\">#{name}<\/span>
  \s*\(<span class=\"covered_percent\"><span class=\"\w+\">([\d\.]*)\%<\/span><\/span>
  \s*covered at
  \s*<span class=\"covered_strength\">
  \s*<span class=\"\w+\">
  \s*(#{number})
  \s*<\/span>
  \s*<\/span> hits\/line\)
  \s*<\/h2>
  \s*<a name=\"#{flat}\"><\/a>
  \s*<div>
  \s*<b>(#{number})<\/b> files in total.
  \s*<b>(#{number})<\/b> relevant lines./m
  r = html.match(pattern)
  h = {}
  h[:coverage]      = f2(r[1])
  h[:hits_per_line] = f2(r[2])
  h[:file_count]    = r[3].to_i
  h[:line_count]    = r[4].to_i
  h[:name] = name
  h
end

# - - - - - - - - - - - - - - - - - - - - - - -

def print_index_stats_for(stats)
  print "#{stats[:name]}:" +
    " Coverage #{stats[:coverage]}%," +
    " files #{stats[:file_count]}," +
    " lines #{stats[:line_count]}," +
    " hits/line #{stats[:hits_per_line]}\n"
end

# - - - - - - - - - - - - - - - - - - - - - - -

def get_test_log_stats
  test_log = `cat #{ARGV[0]}`
  # guard against invalid byte sequence
  test_log = test_log.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
  test_log = test_log.encode('UTF-8', 'UTF-16')

  stats = {}
  finished_pattern = "Finished in (#{number})s, (#{number}) runs/s, (#{number}) assertions/s"
  m = test_log.match(Regexp.new(finished_pattern))
  stats[:time]               = f2(m[1])
  stats[:tests_per_sec]      = m[2].to_i
  stats[:assertions_per_sec] = m[3].to_i

  summary_pattern = %w(runs assertions failures errors skips).map{ |s| "(#{number}) #{s}" }.join(', ')
  m = test_log.match(Regexp.new(summary_pattern))
  stats[:test_count]      = m[1].to_i
  stats[:assertion_count] = m[2].to_i
  stats[:failure_count]   = m[3].to_i
  stats[:error_count]     = m[4].to_i
  stats[:skip_count]      = m[5].to_i

  stats
end

# - - - - - - - - - - - - - - - - - - - - - - -

log_stats = get_test_log_stats
test_stats = get_index_stats('testsrc', 'test/src')
src_stats = get_index_stats('src', 'src')

done =
  [
     [ 'failures == 0', log_stats[:failure_count] <= 0 ],
     [ 'errors == 0', log_stats[:error_count] == 0 ],
     [ 'skips == 0', log_stats[:skip_count] == 0],
     [ 'src(coverage) == 100%', src_stats[:coverage] == '100.00'],
     [ 'test(coverage) == 100%', test_stats[:coverage] == '100.00'],
     [ 'secs < 1', log_stats[:time].to_f < 1 ],
     [ 'assertions per sec > 400', log_stats[:assertions_per_sec] > 400 ],
     [ 'test(lines)/src(lines) > 1.5', (test_stats[:line_count].to_f / src_stats[:line_count].to_f) > 1.5 ],
     [ 'src(hits/line) < 50', src_stats[:hits_per_line].to_f < 50 ],
     [ 'test(hits/line) < 5', test_stats[:hits_per_line].to_f < 5 ]
  ]

yes,no = done.partition { |criteria| criteria[1] }

# - - - - - - - - - - - - - - - - - - - - - - -

print_index_stats_for src_stats
print_index_stats_for test_stats

unless yes.empty?
  print "\n"
  puts "DONE"
  yes.each { |criteria| puts '  ' + criteria[0] }
end

unless no.empty?
  print "\n"
  puts "NOT-DONE"
  no.each { |criteria| puts '  ' + criteria[0] }
  exit 1
else
  exit 0
end

