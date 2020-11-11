# frozen_string_literal: true
require_relative 'git_diff'
require_relative 'git_differ'
require_relative 'git_diff_parser'
require_relative 'prober'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def sha     ; prober.sha     ; end
  def healthy?; prober.healthy?; end
  def alive?  ; prober.alive?  ; end
  def ready?  ; prober.ready?  ; end

  def diff_lines(id:, was_index:, now_index:)
    { 'diff_lines' => git_diff_files(id, was_index, now_index, lines:true) }
  end

  def diff_summary(id:, was_index:, now_index:)
    { 'diff_summary' => git_diff_files(id, was_index, now_index, lines:false) }
  end

  private

  include GitDiffLib

  def git_diff_files(id, was_index, now_index, options)
    was = model.kata_event(id, was_index.to_i)
    now = model.kata_event(id, now_index.to_i)
    was_files = files(was)
    now_files = files(now)
    diff_lines = GitDiffer.new(@externals).diff(id, was_files, now_files)
    diffs = GitDiffParser.new(diff_lines, options).parse_all
    git_diff(diffs, now_files, options)
  end

  def files(event)
    event['files'].map{ |filename, file|
      [filename, file['content']]
    }.to_h
  end

  def model
    @externals.model
  end

  def prober
    @externals.prober
  end

end
