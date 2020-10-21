require_relative 'differ_test_base'

class DiffSummary < DifferTestBase

  def self.id58_prefix
    '4DE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'j12',
  'added empty file' do
    expected = { 'empty.file' => { 'added' => 1, 'deleted' => 0 } }
    actual = diff_summary('RNCzUr', 2, 3)
    assert_equal expected, actual
  end

  test 'j13',
  'deleted empty file' do
    expected = {}
    actual = diff_summary('RNCzUr', 3, 4)
    assert_equal expected, actual
  end

  test 'j14',
  'renamed empty file' do
    expected = {}
    actual = diff_summary('RNCzUr', 5, 6)
    assert_equal expected, actual
  end

  test 'j15',
  'empty file renamed 100% identical across dirs' do
    expected = {}
    actual = diff_summary('RNCzUr', 6, 7)
    assert_equal expected, actual
  end

  test 'j16',
  'empty file has one lines added' do
    expected = {
      'sub_dir/empty.file.rename' => {
        'added' => 1,
        'deleted' => 0
      }
    }
    actual = diff_summary('RNCzUr', 7, 8)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'k15',
  'non-empty file deleted' do
    expected = {
      'readme.txt' => {
        'added' => 0,
        'deleted' => 14
      }
    }
    actual = diff_summary('RNCzUr', 8, 9)
    assert_equal expected, actual
  end

  test 'k16',
  'non-empty file renamed 100% identical' do
    expected = {}
    actual = diff_summary('RNCzUr', 9, 10)
    assert_equal expected, actual
  end

  test 'k17',
  'non-empty file renamed <100% identical' do
    expected = {
      'bats_help.txt' => {
        'added' => 1,
        'deleted' => 1
      }
    }
    actual = diff_summary('RNCzUr', 13, 14)
    assert_equal expected, actual
  end

  test 'k18',
  'two non-empty files both edited' do
    expected = {
      'hiker.sh' => {
        'added' => 1,
        'deleted' => 1
      },
      'readme.txt' => {
        'added' => 6,
        'deleted' => 3
      }
    }
    actual = diff_summary('RNCzUr', 1, 2)
    assert_equal expected, actual
  end

  private

  def diff_summary(id, was_index, now_index)
    differ.diff_summary(id:id, was_index:was_index, now_index:now_index)['diff_summary']
  end

end
