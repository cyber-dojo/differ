require_relative 'git_differ'
require_relative 'git_diff_join'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def ready?
    true
  end

  def sha
    ENV['SHA']
  end

  def diff(was_files, now_files)
    git_diff = GitDiffer.new(@externals).diff(was_files, now_files)
    git_diff_join(git_diff, was_files, now_files)
  end

  private

  include GitDiffJoin

end
