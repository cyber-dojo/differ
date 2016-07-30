require 'sinatra'
require 'sinatra/base'
require 'json'
require_relative './stdout_logger'
require_relative './host_sheller'
require_relative './host_gitter'
require_relative './name_of_caller'
require_relative './unslashed'
require_relative './delta_maker'

class App < Sinatra::Base

  def initialize
    super
    ENV['DIFFER_LOG_CLASS'] = 'StdoutLogger'
    ENV['DIFFER_SHELL_CLASS'] = 'HostSheller'
    ENV['DIFFER_GIT_CLASS'] = 'HostGitter'
    log << "Hello from differ_server.App"
  end

  def log;   @log   ||= external_object; end
  def shell; @shell ||= external_object; end
  def git;   @git   ||= external_object; end

  get '/diff' do

    Dir.mktmpdir('differ') do |tmp_dir|

      #log << "tmp_dir=#{tmp_dir}"
      #shell.exec('git --version')  # 2.4.11 (needs to be 2.9+ for `--compaction-heuristic`)

      # make empty git repo
      user_name = 'differ'
      user_email = user_name + '@cyber-dojo.org'
      git.setup(tmp_dir, user_name, user_email)

      # create sandbox subdir so I don't need to alter parser
      sandbox_dir = tmp_dir + '/' + 'sandbox'
      shell.exec("mkdir #{sandbox_dir}")

      # copy was_files into tag 0
      was_files.each do |filename,content|
        write(sandbox_dir + '/' + filename, content)
        git.add(sandbox_dir, filename)
      end
      git.commit(tmp_dir, was_tag=0)

      # copy now_files into tag 1
      delta = make_delta(was_files, now_files)
      delta[:deleted].each do |filename|
        git.rm(sandbox_dir, filename)
      end
      delta[:new].each do |filename|
        write(sandbox_dir + '/' + filename, now_files[filename])
        git.add(sandbox_dir, filename)
      end
      delta[:changed].each do |filename|
        write(sandbox_dir + '/' + filename, now_files[filename])
      end
      git.commit(tmp_dir, now_tag=1)

      # get the diff
      diff = git.diff(tmp_dir, was_tag, now_tag)

      # combine diff with now_files (app/lib/git_diff.rb)

    end

    content_type :json
    { :was_files => was_files, :now_files => now_files }.to_json
  end

  private

  include NameOfCaller
  include Unslashed
  include DeltaMaker

  def external_object
    key = name_of(caller)
    var = my_env(key + '_class')
    Object.const_get(var).new(self)
  end

  def my_env(suffix)
    name = env_name(suffix)
    unslashed(ENV[name] || fail("ENV[#{name}] not set"))
  end

  def env_name(suffix) #
    'DIFFER_' + suffix.upcase
  end

  # - - - - - - - - - - - - - - - - - - -

  def write(pathed_filename, content)
    # NB: this has no external_object ENV
    File.open(pathed_filename, 'w') { |fd| fd.write(content) }
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


