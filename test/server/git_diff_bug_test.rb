require_relative 'differ_test_base'

class GitDiffBugTest < DifferTestBase

  def self.id58_prefix
    '922'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '827',
  'specific real dojo that once failed a diff' do
    bad_diff_lines =
    [
      'diff --git recently_used_list.cpp was_recently_used_list.test.cpp',
      'similarity index 100%',
      'copy from recently_used_list.cpp',
      'copy to was_recently_used_list.test.cpp',
    ].join("\n")

    diff = GitDiffParser.new(bad_diff_lines).parse_all

    expected =
    [
      {
          old_filename: 'recently_used_list.cpp',
          new_filename: 'was_recently_used_list.test.cpp',
          lines: []
      }
    ]
    assert_equal expected, diff

  end

end
