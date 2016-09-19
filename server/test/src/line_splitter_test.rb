
require_relative './lib_test_base'

class LineSplitterTest < LibTestBase

  def self.hex(suffix)
    'B2B' + suffix
  end

  include LineSplitter

  test 'CCA',
  'splitting nil is an empty array' do
    assert_equal [], line_split(nil)
  end

  #- - - - - - - - - - - - - - - -

  test 'C3D',
  'splitting empty string is empty string in array' do
    assert_equal [ '' ], line_split('')
  end

  #- - - - - - - - - - - - - - - -

  test 'E21',
  'splitting solitary newline is empty string in array' do
    assert_equal [''], line_split("\n")
  end

  #- - - - - - - - - - - - - - - -

  test 'D41',
  'retains empty lines between newlines' do
    # regular split doesn't do what I need...
    assert_equal [], "\n\n".split("\n")
    # So I have to roll my own...
    assert_equal [ '', '' ], line_split("\n"+"\n")
    assert_equal ['a','b',''], line_split('a'+"\n"+'b'+"\n"+"\n")
    assert_equal ['a','b','',''], line_split('a'+"\n"+'b'+"\n"+"\n"+"\n")
  end

  #- - - - - - - - - - - - - - - -

  test 'AEB',
  'doesnt add extra empty line if string ends in newline' do
    assert_equal ['a'], line_split('a')
    assert_equal ['a'], line_split('a'+"\n")
    assert_equal ['a','b'], line_split('a'+"\n"+'b')
    assert_equal ['a','b'], line_split('a'+"\n"+'b'+"\n")
  end

end
