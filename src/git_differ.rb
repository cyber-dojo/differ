require 'securerandom'

class GitDiffer

  def initialize(external)
    @external = external
  end

  def diff(was_files, now_files)
    id = SecureRandom.hex
    Dir.mktmpdir(id, '/tmp') do |git_dir|
      user_name = 'differ'
      user_email = user_name + '@cyber-dojo.org'
      git.setup(git_dir, user_name, user_email)

      was_tag = 0
      save(git_dir, was_files)
      git.add(git_dir, '.')
      git.commit(git_dir, was_tag)

      Dir.mktmpdir(id, '/tmp') do |tmp_dir|
        shell.assert_exec(
          "mv #{git_dir}/.git #{tmp_dir}",
          "rm -rf #{git_dir}",
          "mkdir -p #{git_dir}",
          "mv #{tmp_dir}/.git #{git_dir}"
        )
      end

      now_tag = 1
      save(git_dir, now_files)
      git.add(git_dir, '.')
      git.commit(git_dir, now_tag)

      git.diff(git_dir, was_tag, now_tag)
    end
  end

  private

  def save(dir_name, files)
    files.each do |pathed_filename, content|
      path = File.dirname(pathed_filename)
      src_dir = dir_name + '/' + path
      shell.assert_exec("mkdir -vp #{src_dir}") unless path === '.'
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
