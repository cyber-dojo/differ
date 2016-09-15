#!/bin/sh ../shebang_run.sh

require_relative './lib_test_base'

class ExternalStdoutLoggerTest < LibTestBase

  test '1B6962',
  '<< writes to stdout with added trailing newline' do
    log = ExternalStdoutLogger.new(nil)
    written = with_captured_stdout { log << "Hello world" }
    assert_equal quoted('Hello world')+"\n", written
  end

  private

  def with_captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('','w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  def quoted(s)
    '"' + s + '"'
  end

end
