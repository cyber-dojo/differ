require_relative 'http_json/request_error'
require 'json'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    @args = JSON.parse(body)
    unless @args.is_a?(Hash)
      fail HttpJson::RequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJson::RequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    case path
    when '/ready' then ['ready?',[]]
    when '/sha'   then ['sha',[]]
    when '/diff'  then ['diff',[id, old_files, new_files]]
    else
      raise HttpJson::RequestError, 'unknown path'
    end
  end

  private

  def id
    @args[__method__.to_s]
  end

  def old_files
    @args[__method__.to_s]
  end

  def new_files
    @args[__method__.to_s]
  end

end
