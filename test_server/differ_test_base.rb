require_relative 'hex_mini_test'
require_relative '../src/externals'
require_relative '../src/differ'

class DifferTestBase < HexMiniTest

  def initialize(arg)
    super(arg)
  end

  def diff(was_files, now_files)
    differ.diff(was_files, now_files)
  end

  def differ
    @differ ||= Differ.new(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  def disk
    externals.disk
  end

  def git
    externals.git
  end

  def shell
    externals.shell
  end

  # - - - - - - - - - - - - - - - - - - -

  # :nocov:
  def my_assert_equal(lhs, rhs, message = '')
    if lhs != rhs
      temp_file(:expected, lhs) do |lhs_filename|
        temp_file(:actual, rhs) do |rhs_filename|
          puts `diff #{lhs_filename} #{rhs_filename}`
          message = message.to_s
          message += "\n" + @_hex_test_id
          message += "\n" + @_hex_test_name
          message += "\n" + lhs
          message += "\n" + rhs
          flunk message
        end
      end
    end
  end

  def temp_file(type, obj)
    Tempfile.create(type.to_s, '/tmp') do |tmpfile|
      pathed_filename = tmpfile.path
      IO.write(pathed_filename, JSON.pretty_generate(obj))
      yield pathed_filename
    end
  end
  # :nocov:

=begin
  def with_captured_stderr
    old_stderr = $stderr
    $stderr = StringIO.new('', 'w')
    result = yield
    return [ $stderr.string, result ]
  ensure
    $stderr = old_stderr
  end
=end

end
