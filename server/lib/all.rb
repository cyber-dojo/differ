
%w(
  delta_maker
  file_writer
  git_diff
  host_sheller
  host_gitter
  name_of_caller
  stdout_logger
  unslashed
).each { |file|
  require_relative './' + file
}

