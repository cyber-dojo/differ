# frozen_string_literal: true

require_relative 'git_differ'
require_relative 'git_diff_join'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def sha
    ENV['SHA']
  end

  def alive?
    true
  end
  
  def ready?
    true
  end

  def diff(id, old_files, new_files)
    git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
    git_diff_join(git_diff, old_files, new_files)
  end

  private

  include GitDiffJoin

end
