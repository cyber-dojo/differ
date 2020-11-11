require_relative 'differ_test_base'

class DiffSummaryTest < DifferTestBase

  def self.id58_prefix
    '4DE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'j12',
  'created empty file' do
    assert_diff_summary('RNCzUr', 2, 3,
      :created, nil, 'empty.file', 0,0,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'readme.txt'   , 'readme.txt'   , 0,0,14
    )
  end

  # - - - - - - - - - - - - - -

  test 'j13',
  'deleted empty file' do
    assert_diff_summary('RNCzUr', 3, 4,
      :deleted, 'empty.file', nil, 0,0,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'readme.txt'   , 'readme.txt'   , 0,0,14
    )
  end

  # - - - - - - - - - - - - - -

  test 'j14',
  'renamed empty file' do
    assert_diff_summary('RNCzUr', 5, 6,
      :renamed, 'empty.file', 'empty.file.rename', 0,0,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'readme.txt'   , 'readme.txt'   , 0,0,14
    )
  end

  # - - - - - - - - - - - - - -

  test 'j15',
  'empty file renamed 100% identical across dirs' do
    assert_diff_summary('RNCzUr', 6, 7,
      :renamed, "empty.file.rename", "sub_dir/empty.file.rename", 0,0,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'readme.txt'   , 'readme.txt'   , 0,0,14
    )
  end

  # - - - - - - - - - - - - - -

  test 'j16',
  'empty file has one lines added' do
    assert_diff_summary('RNCzUr', 7, 8,
      :changed, "sub_dir/empty.file.rename", "sub_dir/empty.file.rename", 1,0,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'readme.txt'   , 'readme.txt'   , 0,0,14
    )
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'k15',
  'non-empty file deleted' do
    assert_diff_summary('RNCzUr', 8, 9,
      :deleted, "readme.txt", nil, 0,14,0,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'sub_dir/empty.file.rename', 'sub_dir/empty.file.rename', 0,0,1
    )
  end

  # - - - - - - - - - - - - - -

  test 'k16',
  'non-empty file renamed 100% identical' do
    assert_diff_summary('RNCzUr', 9, 10,
      :renamed, "bats_help.txt", "bats_help.txt.rename", 0,0,3,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'sub_dir/empty.file.rename', 'sub_dir/empty.file.rename', 0,0,1
    )
  end

  # - - - - - - - - - - - - - -

  test 'k17',
  'non-empty file renamed <100% identical' do
    assert_diff_summary('RNCzUr', 13, 14,
      :changed, "bats_help.txt", "bats_help.txt", 1,1,19, # data error. No rename here.
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'hiker.sh'     , 'hiker.sh'     , 0,0,6,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
      :unchanged, 'sub_dir/empty.file.rename', 'sub_dir/empty.file.rename', 0,0,1
    )
  end

  # - - - - - - - - - - - - - -

  test 'k18',
  'two non-empty files both edited' do
    assert_diff_summary('RNCzUr', 1, 2,
      :changed, "hiker.sh", "hiker.sh", 1,1,5,
      :changed, "readme.txt", "readme.txt", 6,3,8,
      :unchanged, 'test_hiker.sh', 'test_hiker.sh', 0,0,8,
      :unchanged, 'bats_help.txt', 'bats_help.txt', 0,0,3,
      :unchanged, 'cyber-dojo.sh', 'cyber-dojo.sh', 0,0,2,
    )
  end

  private

  def assert_diff_summary(id, was_index, now_index, *diffs)
    expected = diffs.each_slice(6).to_a.map do |diff|
      { type: diff[0],
        old_filename: diff[1],
        new_filename: diff[2],
        line_counts: { added:diff[3], deleted:diff[4], same:diff[5] }
      }
    end
    actual = diff_summary(id, was_index, now_index)
    assert_equal expected, actual
  end

  def diff_summary(id, was_index, now_index)
    differ.diff_summary(id:id, was_index:was_index, now_index:now_index)['diff_summary']
  end

end
