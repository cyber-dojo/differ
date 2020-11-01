# frozen_string_literal: true
require_relative 'git_differ'
require_relative 'git_diff_join'
require_relative 'git_diff_lib'
#require_relative 'git_diff_lines'
require_relative 'git_diff_parser'
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
    git_diff = GitDiffer.new(@externals).diff(id, old_files, new_files)
    result = git_diff_join(git_diff, old_files, new_files)
    { 'diff' => result }
  end

=begin
  def diff_lines2(id:, old_files:, new_files:)
    diff_lines = GitDiffer.new(@externals).diff(id, old_files, new_files)
    diffs = GitDiffParser.new(diff_lines, :both).parse_all
    { 'diff_lines2' => git_diff_lines(diffs, new_files) }
  end
=end

  def diff_summary2(id:, was_index:, now_index:)
    # args from request query will be strings
    was_files = model_files(id, was_index.to_i)
    now_files = model_files(id, now_index.to_i)
    diff_lines = GitDiffer.new(@externals).diff(id, was_files, now_files)
    diffs = GitDiffParser.new(diff_lines, :summary).parse_all
    { 'diff_summary2' => git_diff_summary(diffs, now_files) }
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
