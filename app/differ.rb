# frozen_string_literal: true
require_relative 'git_differ'
require_relative 'git_diff_lib'
require_relative 'prober'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def alive?; prober.alive?; end
  def ready?; prober.ready?; end
  def sha; prober.sha; end

  def diff(id:, old_files:, new_files:)
    git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
    result = git_diff_join(git_diff, old_files, new_files)
    { 'diff' => result }
  end

  def diff_tip_data(id:, old_files:, new_files:)
    git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
    result = git_diff_tip_data(git_diff, old_files, new_files)
    { 'diff_tip_data' => result }
  end

  private

  include GitDiffLib

  def prober
    Prober.new(@externals)
  end

end
