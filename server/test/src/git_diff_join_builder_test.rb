require_relative 'differ_test_base'
require_relative '../../src/git_diff_join_builder'
class GitDiffJoinBuilderTest < DifferTestBase
  def self.hex_prefix; 'A33'; end
  test 'F3C',