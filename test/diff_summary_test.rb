require_relative 'differ_test_base'

class DiffSummaryTest < DifferTestBase

  def self.id58_prefix
    '4DE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  test 'j12',
  'added empty file' do
    expected = [
      { 'old_filename' => nil,
        'new_filename' => 'empty.file',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    actual = diff_summary('RNCzUr', 2, 3)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'j13',
  'deleted empty file' do
    expected = [
      { 'old_filename' => 'empty.file',
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    actual = diff_summary('RNCzUr', 3, 4)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'j14',
  'renamed empty file' do
    expected = [
      { 'old_filename' => 'empty.file',
        'new_filename' => 'empty.file.rename',
        'line_counts' => { 'added' => 0, 'deleted' => 0, 'same' => 0 }
      }
    ]
    actual = diff_summary('RNCzUr', 5, 6)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'j15',
  'empty file renamed 100% identical across dirs' do
    expected = [
      { "old_filename" => "empty.file.rename",
        "new_filename" => "sub_dir/empty.file.rename",
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>0 }
      }
    ]
    actual = diff_summary('RNCzUr', 6, 7)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'j16',
  'empty file has one lines added' do
    expected = [
      {
        "old_filename" => "sub_dir/empty.file.rename",
        "new_filename" => "sub_dir/empty.file.rename",
        "line_counts" => { "added"=>1, "deleted"=>0, "same"=>0 }
      }
    ]
    actual = diff_summary('RNCzUr', 7, 8)
    assert_equal expected, actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'k15',
  'non-empty file deleted' do
    expected = [
      { "old_filename" => "readme.txt",
        "new_filename" => nil,
        "line_counts" => { "added"=>0, "deleted"=>14, "same"=>0 }
      }
    ]
    actual = diff_summary('RNCzUr', 8, 9)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'k16',
  'non-empty file renamed 100% identical' do
    expected = [
      { "old_filename" => "bats_help.txt",
        "new_filename" => "bats_help.txt.rename",
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>3 }
      }
    ]
    actual = diff_summary('RNCzUr', 9, 10)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'k17',
  'non-empty file renamed <100% identical' do
    expected = [
      { "old_filename" => "bats_help.txt",
        "new_filename" => "bats_help.txt",
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=>19 }
      }
    ]
    actual = diff_summary('RNCzUr', 13, 14)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - -

  test 'k18',
  'two non-empty files both edited' do
    expected = [
      { "old_filename" => "hiker.sh",
        "new_filename" => "hiker.sh",
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=>5 }
      },
      { "old_filename" => "readme.txt",
        "new_filename" => "readme.txt",
        "line_counts" => { "added"=>6, "deleted"=>3, "same"=>8 }
      }
    ]
    actual = diff_summary('RNCzUr', 1, 2)
    assert_equal expected, actual
  end

  private

  def diff_summary(id, was_index, now_index)
    differ.diff_summary2(id:id, was_index:was_index, now_index:now_index)['diff_summary2']
  end

end
