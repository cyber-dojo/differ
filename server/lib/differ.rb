
require_relative './delta_maker'
require_relative './externals'
require_relative './git_diff'

class Differ

  def initialize(was_files, now_files)
    @delta = make_delta(was_files, now_files)
    @now_files = now_files
  end

  def diff
    Dir.mktmpdir('differ') do |git_dir|
      make_empty_git_repo_in(git_dir)

      was_tag = 0
      write_files_into(git_dir)
      git.commit(git_dir, was_tag)

      now_tag = 1
      write_new_files_to(git_dir)
      delete_deleted_files_from(git_dir)
      overwrite_changed_files_in(git_dir)
      git.commit(git_dir, now_tag)

      diff_lines = git.diff(git_dir, was_tag, now_tag)
      git_diff(diff_lines, now_files)
    end
  end

  include Externals

  private

  attr_reader :delta, :now_files

  def make_empty_git_repo_in(git_dir)
    user_name = 'differ'
    user_email = user_name + '@cyber-dojo.org'
    git.setup(git_dir, user_name, user_email)
  end

  def write_files_into(git_dir)
    was_files.each do |filename, content|
      file.write(git_dir + '/' + filename, content)
      git.add(git_dir, filename)
    end
  end

  def write_new_files_to(git_dir)
    delta[:new].each do |filename|
      file.write(git_dir + '/' + filename, now_files[filename])
      git.add(git_dir, filename)
    end
  end

  def delete_deleted_files_from(git_dir)
    delta[:deleted].each do |filename|
      git.rm(git_dir, filename)
    end
  end

  def overwrite_changed_files_in(git_dir)
    delta[:changed].each do |filename|
      file.write(git_dir + '/' + filename, now_files[filename])
    end
  end

  include DeltaMaker
  include GitDiff

end
