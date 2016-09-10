
module TestExternalHelpers # mix-in

  module_function

  def setup
    raise "setup already called" unless @setup_called.nil?
    @setup_called = true
    @config = {}
    env_map.keys.each { |key| @config[key] = ENV[key] }
  end

  def teardown
    fail_if_setup_not_called('teardown')
    env_map.keys.each { |key| ENV[key] = @config[key] }
    @setup_called = nil
  end

  def fail_if_setup_not_called(cmd)
    fail "#{cmd} NOT executed because setup() not yet called" if @setup_called.nil?
  end

end
