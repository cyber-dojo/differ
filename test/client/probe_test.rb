require_relative 'client_test_base'

class ProbeTest < ClientTestBase

  test '4q0jj8', %w(
  | clients use probes with a trailing question mark in their path which is overly cute
  | so support both with and without ? until all clients have switched to non ?
  ) do
    http = differ.instance_variable_get(:@http)
    assert http.get('alive?', {}).instance_of?(TrueClass)
    assert http.get('alive', {}).instance_of?(TrueClass)
  end

  test '4q0944', %w(
  | probes 200
  ) do
    assert differ.alive.instance_of?(TrueClass)
    assert differ.ready.instance_of?(TrueClass)
  end

  test '4q0945', %w(
  | sha 200
  ) do
    sha = differ.sha
    assert_equal 40, sha.size, 'sha.size'
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch), ch
    end
  end

end
