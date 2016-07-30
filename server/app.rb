require 'sinatra'
require 'sinatra/base'
require 'json'
require_relative './stdout_logger'
require_relative './host_sheller'
require_relative './host_gitter'

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
      # make empty git repo
      user_name = 'differ'
      user_email = user_name + '@cyber-dojo.org'
      git.setup(tmp_dir, user_name, user_email)

      # copy was_files
      # tag 0
      # create delta between was_files and now_files
      # using delta... (lib/host_disk_katas.rb sandbox_save())
      #     git rm deleted files
      #     git add new files
      #     git add changed files
      # tag 1
      # get the diff
      # combine diff with now_files (app/lib/git_diff.rb)

    end

    content_type :json
    { :was_files => was_files, :now_files => now_files }.to_json
  end

  private

  def name_of(caller)
    # eg caller[0] == "app.rb:12:in `log'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

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

  def unslashed(path)
    path.chomp('/')
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


