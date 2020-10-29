# frozen_string_literal: true
require_relative 'git_differ'
require_relative 'git_diff_lib'
require_relative 'git_diff_summary'
require_relative 'prober'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def sha     ; prober.sha     ; end
  def healthy?; prober.healthy?; end
  def alive?  ; prober.alive?  ; end
  def ready?  ; prober.ready?  ; end

  def diff(id:, old_files:, new_files:)
    git_diff = GitDiffer.new(@externals).diff(old_files, new_files)
    result = git_diff_join(git_diff, old_files, new_files)
    { 'diff' => result }
  end

  def diff_summary(id:, was_index:, now_index:)
    # args from JSON body will retain their type
    # args from request query will be strings
    was_index = was_index.to_i
    now_index = now_index.to_i
    was_files = model_files(id, was_index)
    now_files = model_files(id, now_index)
    git_diff = GitDiffer.new(@externals).diff(was_files, now_files)
    result = git_diff_tip_data(git_diff, was_files, now_files)
    { 'diff_summary' => result }
  end

  def diff_summary2(id:, was_index:, now_index:)
    # args from request query will be strings
    was_files = model_files(id, was_index.to_i)
    now_files = model_files(id, now_index.to_i)
    { 'diff_summary2' => git_diff_summary(was_files, now_files) }
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
