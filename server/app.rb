require 'sinatra'
require 'sinatra/base'
require 'json'

%w(
  delta_maker
  file_writer
  git_diff
  host_sheller
  host_gitter
  name_of_caller
  stdout_logger
  unslashed
).each { |file|
  require_relative './lib/' + file
}

# - - - - - - - - - - - - - - - - - - - - - - - -

class App < Sinatra::Base

  get '/diff' do
    content_type :json
    diff.to_json
  end

  private

  def diff
    Dir.mktmpdir('differ') do |git_dir|
      make_empty_git_repo_in(git_dir)

      write_files_into(git_dir)
      git.commit(git_dir, was_tag=0)

      write_new_files_to(git_dir)
      delete_deleted_files_from(git_dir)
      overwrite_changed_files_in(git_dir)
      git.commit(git_dir, now_tag=1)

      diff_lines = git.diff(git_dir, was_tag, now_tag)
      git_diff(diff_lines, now_files)
    end
  end

  def make_empty_git_repo_in(git_dir)
    user_name = 'nobody'
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

  def delta
    make_delta(was_files, now_files)
  end

  def was_files
    arg['was_files']
  end

  def now_files
    arg['now_files']
  end

  def arg
    @arg ||= JSON.parse(request.body.read)
  end

  def log;   @log   ||= external_object; end
  def shell; @shell ||= external_object; end
  def git;   @git   ||= external_object; end
  def file;  @file  ||= external_object; end

  def external_object
    name = 'DIFFER_CLASS_' + name_of(caller).upcase
    var = unslashed(ENV[name] || fail("ENV[#{name}] not set"))
    Object.const_get(var).new(self)
  end

  include NameOfCaller
  include Unslashed
  include DeltaMaker
  include GitDiff

end


