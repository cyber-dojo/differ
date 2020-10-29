require_relative 'differ_test_base'

class DiffSummaryTest < DifferTestBase

  def self.id58_prefix
    '4DE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'j12',
  'added empty file' do
    assert_diff_summary('RNCzUr', 2, 3, nil, 'empty.file', 0,0,0)
  end

  # - - - - - - - - - - - - - -

  test 'j13',
  'deleted empty file' do
    assert_diff_summary('RNCzUr', 3, 4,
      'empty.file', nil,
      0,0,0
    )
  end

  # - - - - - - - - - - - - - -

  test 'j14',
  'renamed empty file' do
    assert_diff_summary('RNCzUr', 5, 6,
      'empty.file', 'empty.file.rename',
      0,0,0
    )
  end

  # - - - - - - - - - - - - - -

  test 'j15',
  'empty file renamed 100% identical across dirs' do
    assert_diff_summary('RNCzUr', 6, 7,
      "empty.file.rename", "sub_dir/empty.file.rename",
      0,0,0
    )
  end

  # - - - - - - - - - - - - - -

  test 'j16',
  'empty file has one lines added' do
    assert_diff_summary('RNCzUr', 7, 8,
      "sub_dir/empty.file.rename", "sub_dir/empty.file.rename",
      1,0,0)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'k15',
  'non-empty file deleted' do
    assert_diff_summary('RNCzUr', 8, 9,
      "readme.txt", nil, 0,14,0
    )
  end

  # - - - - - - - - - - - - - -

  test 'k16',
  'non-empty file renamed 100% identical' do
    assert_diff_summary('RNCzUr', 9, 10,
      "bats_help.txt", "bats_help.txt.rename",
      0,0,3
    )
  end

  # - - - - - - - - - - - - - -

  test 'k17',
  'non-empty file renamed <100% identical' do
    assert_diff_summary('RNCzUr', 13, 14,
      "bats_help.txt", "bats_help.txt",
      1,1,19
    )
  end

  # - - - - - - - - - - - - - -

  test 'k18',
  'two non-empty files both edited' do
    assert_diff_summary('RNCzUr', 1, 2,
      "hiker.sh", "hiker.sh",
      1,1,5,
      "readme.txt", "readme.txt",
      6,3,8
    )
  end

  private

  def assert_diff_summary(id, was_index, now_index, *diffs)
    expected = diffs.each_slice(5).to_a.map do |diff|
      { 'old_filename' => diff[0],
        'new_filename' => diff[1],
        'line_counts' => { 'added' => diff[2], 'deleted' => diff[3], 'same' => diff[4] }
      }
    end
    actual = diff_summary(id, was_index, now_index)
    assert_equal expected, actual
  end

  def diff_summary(id, was_index, now_index)
    differ.diff_summary2(id:id, was_index:was_index, now_index:now_index)['diff_summary2']
  end

end
