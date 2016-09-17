
require_relative './lib_test_base'

class NameOfCallerTest < LibTestBase

  def self.hex(suffix)
    '07A' + suffix
  end

  include NameOfCaller

  test 'DA9',
  'name of caller is name of callers method' do
    assert_equal 'helper1', helper1
    assert_equal 'helper2', helper2
  end

  test '5C2',
  'name of caller is name of callers method' do
  end

  private

  def helper1
    helper
  end

  def helper2
    helper
  end

  def helper
    name_of(caller)
  end

end
