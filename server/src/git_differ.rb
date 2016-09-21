
require_relative './delta_maker'
require_relative './external_parent_chainer'

class GitDiffer

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(was_files, now_files)
    @was_files = was_files
    @now_files = now_files
    @delta = make_delta(was_files, now_files)
    Dir.mktmpdir('differ') do |git_dir|
      make_empty_git_repo_in(git_dir)

      was_tag = 0
      write_was_files_into(git_dir)
      git.commit(git_dir, was_tag)

      now_tag = 1
      write_new_files_to(git_dir)
      delete_deleted_files_from(git_dir)
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
  include ExternalParentChainer

end
