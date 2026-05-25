require_relative 'client_test_base'

class ErrorsTest < ClientTestBase

  # - - - - - - - - - - - - - - - - - - - -
  # >10K query was a problem for thin at one time
  # - - - - - - - - - - - - - - - - - - - -

  test '3q0347', %w(
  | >10K query is not rejected by web server
  ) do
    old_files = { 'wibble.h' => 'X' * 45 * 1024 }
    differ.diff_summary(was_files: old_files, now_files: {})
  end

  test '3q0348', %w(
  | >10K query in nested sub-dir is not rejected by web-server
  ) do
    old_files = { 'gh/jk/wibble.h' => 'X' * 45 * 1024 }
    differ.diff_summary(was_files: old_files, now_files: {})
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '3q07C0', %w(
  | calling unknown method raises
  ) do
    http = differ.instance_variable_get(:@http)
    error = assert_raises(RuntimeError) { http.get(:shar, { x: 42 }) }
    json = JSON.parse(error.message)
    expected = {
      'request' => {
        'service' => 'differ',
        'path' => 'shar',
        'args' => { 'x' => 42 }
      },
      'response' => {
        'body' => '<h1>Not Found</h1>'
      },
      'message' => 'body is not JSON'
    }
    assert_equal expected, json
  end

end
