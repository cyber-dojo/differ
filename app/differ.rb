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

  def diff_summary(id:, was_index:, now_index:, version:nil,avatar_index:nil,number:nil)
    was_files = model_files(id, was_index)
    now_files = model_files(id, now_index)
    git_diff = GitDiffer.new(@externals).diff(id, was_files, now_files)
    result = git_diff_tip_data(git_diff, was_files, now_files)
    { 'diff_summary' => result }
  end

  def diff_summary2(id:, was_index:, now_index:)
    { 'diff_summary2' => [
        { 'old_filename' => "hiker.h",
          'new_filename' => "hiker.hpp",
          'counts' => { 'added' => 0, 'deleted' => 0, 'same' => 23 },
          'lines' => []
        }
      ]
    }
  end

  private

  include GitDiffLib

  # - - - - - - - - - - - - -

  def model_files(id, index)
    model.kata_event(id, index)['files'].map{|filename, file|
      [filename, file['content']]
    }.to_h
  end

  # - - - - - - - - - - - - -

  def model
    @externals.model
  end

  def prober
    @externals.prober
  end

end
