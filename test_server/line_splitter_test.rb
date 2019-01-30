require_relative 'differ_test_base'
require_relative '../src/line_splitter'

class LineSplitterTest < DifferTestBase

  def self.hex_prefix
    'B2B'
  end

  include LineSplitter

  test 'CCA',
  'splitting nil is an empty array' do
    assert_line_split [], nil
  end

  #- - - - - - - - - - - - - - - -

  test 'C3D',
  'splitting empty string is empty string in array' do
    assert_line_split [ '' ], ''
  end

  #- - - - - - - - - - - - - - - -

  test 'E21',
  'splitting solitary newline is empty string in array' do
    assert_line_split [''], "\n"
  end

  #- - - - - - - - - - - - - - - -

  test 'D41',
  'retains empty lines between newlines' do
    # regular split doesn't do what I need...
    assert_equal [], "\n\n".split("\n")
    # So I have to roll my own...
    assert_line_split [ '', '' ], "\n"+"\n"
    assert_line_split ['a','b',''], 'a'+"\n"+'b'+"\n"+"\n"
    assert_line_split ['a','b','',''], 'a'+"\n"+'b'+"\n"+"\n"+"\n"
  end

  #- - - - - - - - - - - - - - - -

  test 'AEB',
  'doesnt add extra empty line if string ends in newline' do
    assert_line_split ['a'], 'a'
    assert_line_split ['a'], 'a'+"\n"
    assert_line_split ['a','b'], 'a'+"\n"+'b'
    assert_line_split ['a','b'], 'a'+"\n"+'b'+"\n"
  end

  #- - - - - - - - - - - - - - - -

  def assert_line_split expected, line
    assert_equal expected, line_split(line)
  end

end
