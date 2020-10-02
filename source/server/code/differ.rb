# frozen_string_literal: true
require_relative 'git_differ'
require_relative 'git_diff_lib'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def sha
    { 'sha' => ENV['SHA'] }
  end

  def alive?
    { 'alive?' => true }
  end

  def ready?
    { 'ready?' => true }
  end

  def diff(id:, old_files:, new_files:)
    git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
    result = git_diff_join(git_diff, old_files, new_files)
    { 'diff' => result }
  end

  #def diff_tip_data(id:, old_files:, new_files:)
  #  git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
  #  result = git_diff_tip_data(git_diff, old_files, new_files)
  #  { 'diff_tip_data' => result }
  #end

  private

  include GitDiffLib

end
