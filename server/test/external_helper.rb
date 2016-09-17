
module TestExternalHelper # mix-in

  module_function

  def setup
    raise 'setup() already called' unless @setup_called.nil?
    @setup_called = true
    @config = {}
    env_map.keys.each { |key| @config[key] = ENV[key] }
  end

  def teardown
    fail 'teardown() NOT executed because setup() not yet called' if @setup_called.nil?
    env_map.keys.each { |key| ENV[key] = @config[key] }
    @setup_called = nil
  end

end
