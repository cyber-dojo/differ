
module TestExternalHelpers # mix-in

  module_function

  def setup
    raise "setup already called" unless @setup_called.nil?
    @setup_called = true
    @config = {}
    %w( LOG SHELL GIT FILE ).each do |suffix|
      key = $differ_env_root + suffix
      @config[key] = ENV[key]
    end
  end

  def teardown
    fail_if_setup_not_called('teardown')
    %w( LOG SHELL GIT FILE ).each do |suffix|
      key = $differ_env_root + suffix
      ENV[key] = @config[key]
    end
    @setup_called = nil
  end

  def fail_if_setup_not_called(cmd)
    fail "#{cmd} NOT executed because setup() not yet called" if @setup_called.nil?
  end

end
