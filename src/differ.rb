require_relative 'git_differ'
require_relative 'git_diff_join'

class Differ

  def initialize(external)
    @external = external
  end

  def sha
    ENV['SHA']
  end

  def diff(was_files, now_files)
    git_diff = GitDiffer.new(@external).diff(was_files, now_files)
    git_diff_join(git_diff, now_files)
  end

  private

  include GitDiffJoin

end
