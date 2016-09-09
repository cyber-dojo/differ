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
    Dir.mktmpdir('differ') do |tmp_dir|
      @tmp_dir = tmp_dir
      make_empty_git_repo
      create_sandbox_dir
      copy_was_files_into_tag_0
      add_remove_copy_now_files_into_tag_1
      diff_lines = git.diff(tmp_dir, 0, 1)
      git_diff(diff_lines, now_files)
    end
  end

  def make_empty_git_repo
    user_name = 'nobody'
    user_email = user_name + '@cyber-dojo.org'
    git.setup(@tmp_dir, user_name, user_email)
  end

  def sandbox_dir
    @tmp_dir + '/' + 'sandbox'
  end

  def create_sandbox_dir
    # so I don't need to alter parser
    shell.exec("mkdir #{sandbox_dir}")
  end

  def copy_was_files_into_tag_0
    was_files.each do |filename,content|
      file.write(sandbox_dir + '/' + filename, content)
      git.add(sandbox_dir, filename)
    end
    git.commit(@tmp_dir, was_tag=0)
  end

  def add_remove_copy_now_files_into_tag_1
    delta = make_delta(was_files, now_files)
    delta[:new].each do |filename|
      file.write(sandbox_dir + '/' + filename, now_files[filename])
      git.add(sandbox_dir, filename)
    end
    delta[:deleted].each do |filename|
      git.rm(sandbox_dir, filename)
    end
    delta[:changed].each do |filename|
      file.write(sandbox_dir + '/' + filename, now_files[filename])
    end
    git.commit(@tmp_dir, now_tag=1)
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

  def was_files
    arg['was_files']
  end

  def now_files
    arg['now_files']
  end

  def arg
    @arg ||= JSON.parse(request.body.read)
  end

  include NameOfCaller
  include Unslashed
  include DeltaMaker
  include GitDiff

end


