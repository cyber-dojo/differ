require 'sinatra'
require 'sinatra/base'
require 'json'

require_relative './lib/all'

class App < Sinatra::Base

  get '/diff' do
    content_type :json
    differ.diff(was_files, now_files).to_json
  end

  private

  def was_files; arg['was_files']; end
  def now_files; arg['now_files']; end
  def arg; @arg ||= JSON.parse(request.body.read); end

  def differ; Differ.new(self); end

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

end


