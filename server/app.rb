require 'sinatra'
require 'sinatra/base'
require 'json'
require_relative './stdout_logger'
require_relative './host_sheller'
require_relative './host_gitter'
require_relative './file_writer'
require_relative './name_of_caller'
require_relative './unslashed'
require_relative './delta_maker'
require_relative './git_diff'

class App < Sinatra::Base

  def initialize
    super
    ENV['DIFFER_CLASS_LOG']   = 'StdoutLogger'
    ENV['DIFFER_CLASS_SHELL'] = 'HostSheller'
    ENV['DIFFER_CLASS_GIT']   = 'HostGitter'
    ENV['DIFFER_CLASS_FILE']  = 'FileWriter'
  end

  def log;   @log   ||= external_object; end
  def shell; @shell ||= external_object; end
  def git;   @git   ||= external_object; end
  def file;  @file  ||= external_object; end

  get '/diff' do
    diff = nil
    Dir.mktmpdir('differ') do |tmp_dir|
      # make empty git repo
      user_name = 'differ'
      user_email = user_name + '@cyber-dojo.org'
      git.setup(tmp_dir, user_name, user_email)

      # create sandbox subdir so I don't need to alter parser
      sandbox_dir = tmp_dir + '/' + 'sandbox'
      shell.exec("mkdir #{sandbox_dir}")

      # copy was_files into tag 0
      was_files.each do |filename,content|
        file.write(sandbox_dir + '/' + filename, content)
        git.add(sandbox_dir, filename)
      end
      git.commit(tmp_dir, was_tag=0)

      # copy now_files into tag 1
      delta = make_delta(was_files, now_files)
      delta[:deleted].each do |filename|
        git.rm(sandbox_dir, filename)
      end
      delta[:new].each do |filename|
        file.write(sandbox_dir + '/' + filename, now_files[filename])
        git.add(sandbox_dir, filename)
      end
      delta[:changed].each do |filename|
        file.write(sandbox_dir + '/' + filename, now_files[filename])
      end
      git.commit(tmp_dir, now_tag=1)

      # get the diff
      diff_lines = git.diff(tmp_dir, was_tag, now_tag)
      diff = git_diff(diff_lines, now_files)
    end

    content_type :json
    diff.to_json
  end

  private

  include NameOfCaller
  include Unslashed
  include DeltaMaker
  include GitDiff

  def external_object
    name = 'DIFFER_CLASS_' + name_of(caller).upcase
    var = unslashed(ENV[name] || fail("ENV[#{name}] not set"))
    Object.const_get(var).new(self)
  end

  # - - - - - - - - - - - - - - - - - - -

  def was_files
    arg['was_files']
  end

  def now_files
    arg['now_files']
  end

  def arg
    @arg ||= JSON.parse(request.body.read)
  end

end


