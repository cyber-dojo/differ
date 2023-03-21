# frozen_string_literal: true

class GitDiffer
  def initialize(external)
    @external = external
  end

  def diff(id, old_files, new_files)
    Dir.mktmpdir(id, '/tmp') do |git_dir|
      git.setup(git_dir)
      save(git_dir, old_files)
      git.add_commit_tag_0(git_dir)
      remove_content_from(id, git_dir)
      save(git_dir, new_files)
      git.add_commit_tag_1(git_dir)
      git.diff_0_1(git_dir)
    end
  end

  private

  def remove_content_from(id, git_dir)
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
      src_dir = "#{dir_name}/#{path}"
      shell.assert_exec("mkdir -vp #{src_dir}") unless path == '.'
      disk.write("#{dir_name}/#{pathed_filename}", content)
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
