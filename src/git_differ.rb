require 'securerandom'

class GitDiffer

  def initialize(external)
    @external = external
  end

  def diff(old_files, new_files)
    id = SecureRandom.hex
    Dir.mktmpdir(id, '/tmp') do |git_dir|
      user_name = 'differ'
      user_email = user_name + '@cyber-dojo.org'
      git.setup(git_dir, user_name, user_email)
      add_and_commit(git_dir, old_files, old_tag = 0)
      remove_content_from(git_dir, id)
      add_and_commit(git_dir, new_files, new_tag = 1)
      git.diff(git_dir, old_tag, new_tag)
    end
  end

  private

  def add_and_commit(git_dir, files, tag)
    save(git_dir, files)
    git.add(git_dir, '.')
    git.commit(git_dir, tag)
  end

  def remove_content_from(git_dir, id)
    Dir.mktmpdir(id, '/tmp') do |tmp_dir|
      shell.assert_exec(
        "mv #{git_dir}/.git #{tmp_dir}",
        "rm -rf #{git_dir}",
        "mkdir -p #{git_dir}",
        "mv #{tmp_dir}/.git #{git_dir}"
      )
    end
  end

  def save(dir_name, files)
    files.each do |pathed_filename, content|
      path = File.dirname(pathed_filename)
      src_dir = dir_name + '/' + path
      unless path === '.'
        shell.assert_exec("mkdir -vp #{src_dir}")
      end
      disk.write(dir_name + '/' + pathed_filename, content)
    end
  end

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
