require_relative 'delta_maker'
require 'securerandom'

class GitDiffer

  def initialize(external)
    @external = external
  end

  def diff(was_files, now_files)
    @was_files = was_files
    @now_files = now_files
    @delta = make_delta(was_files, now_files)
    id = SecureRandom.hex
    Dir.mktmpdir(id, '/tmp') do |git_dir|
      make_empty_git_repo_in(git_dir)

      was_tag = 0
      write_was_files_into(git_dir)
      git.commit(git_dir, was_tag)

      now_tag = 1
      delete_deleted_files_from(git_dir)
      write_new_files_to(git_dir)
      overwrite_changed_files_in(git_dir)
      git.commit(git_dir, now_tag)

      git.diff(git_dir, was_tag, now_tag)
    end
  end

  private

  attr_reader :delta, :was_files, :now_files

  def make_empty_git_repo_in(git_dir)
    user_name = 'differ'
    user_email = user_name + '@cyber-dojo.org'
    git.setup(git_dir, user_name, user_email)
  end

  def write_was_files_into(git_dir)
    was_files.each do |pathed_filename, content|
      path = File.dirname(pathed_filename)
      src_dir = git_dir + '/' + path
      shell.assert_exec("mkdir -vp #{src_dir}") if path != '.'
      disk.write(git_dir + '/' + pathed_filename, content)
      git.add(git_dir, pathed_filename)
    end
  end

  def delete_deleted_files_from(git_dir)
    delta[:deleted].each do |filename|
      git.rm(git_dir, filename)
    end
  end

  def write_new_files_to(git_dir)
    delta[:new].each do |pathed_filename|
      path = File.dirname(pathed_filename)
      src_dir = git_dir + '/' + path
      shell.assert_exec("mkdir -vp #{src_dir}") if path != '.'
      disk.write(git_dir + '/' + pathed_filename, now_files[pathed_filename])
      git.add(git_dir, pathed_filename)
    end
  end

  def overwrite_changed_files_in(git_dir)
    delta[:changed].each do |filename|
      disk.write(git_dir + '/' + filename, now_files[filename])
    end
  end

  include DeltaMaker

  def disk
    @external.disk
  end

  def git
    @external.git
  end

  def shell
    @external.shell
  end

end
