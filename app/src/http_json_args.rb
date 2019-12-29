# frozen_string_literal: true

require_relative 'http_json/request_error'
require 'oj'

class HttpJsonArgs

  def initialize(body)
    @args = json_parse(body)
    unless @args.is_a?(Hash)
      raise request_error('body is not JSON Hash')
    end
  rescue Oj::ParseError
    raise request_error('body is not JSON')
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    case path
    when '/sha'   then ['sha',[]]
    when '/alive' then ['alive?',[]]
    when '/ready' then ['ready?',[]]
    when '/diff'  then ['diff',[id, old_files, new_files]]
    else
      raise request_error('unknown path')
    end
  end

  private

  def json_parse(body)
    if body === ''
      {}
    else
      Oj.strict_load(body)
    end
  end

  # - - - - - - - - - - - - - - - -

  def id
    exists_arg('id')
  end

  def old_files
    exists_arg('old_files')
  end

  def new_files
    exists_arg('new_files')
  end

  # - - - - - - - - - - - - - - - -

  def exists_arg(name)
    unless @args.has_key?(name)
      raise missing(name)
    end
    arg = @args[name]
    arg
  end

  # - - - - - - - - - - - - - - - -

  def missing(arg_name)
    request_error("#{arg_name} is missing")
  end

  # - - - - - - - - - - - - - - - -

  def request_error(text)
    # Exception messages use the words 'body' and 'path'
    # to match RackDispatcher's exception keys.
    HttpJson::RequestError.new(text)
  end

end
