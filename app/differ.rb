# frozen_string_literal: true
require_relative 'git_diff'
require_relative 'git_differ'
require_relative 'git_diff_parser'

class Differ

  def initialize(externals)
    @externals = externals
  end

  def diff_lines(id:, was_index:, now_index:)
    git_diff_files(id, was_index, now_index, lines:true)
  end

  def diff_summary(id:, was_index:, now_index:)
    git_diff_files(id, was_index, now_index, lines:false)
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

end
