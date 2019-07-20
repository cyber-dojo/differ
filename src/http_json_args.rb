require_relative 'base58'
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
    name = __method__.to_s
    unless @args.has_key?(name)
      fail missing(name)
    end
    arg = @args[name]
    unless well_formed_id?(arg)
      fail malformed(name)
    end
    arg
  end

  def well_formed_id?(arg)
    Base58.string?(arg) && arg.size === 6
  end

  # - - - - - - - - - - - - - - - -

  def old_files
    @args[__method__.to_s]
  end

  def new_files
    @args[__method__.to_s]
  end

  # - - - - - - - - - - - - - - - -

  def missing(arg_name)
    HttpJson::RequestError.new("#{arg_name} is missing")
  end

  def malformed(arg_name)
    HttpJson::RequestError.new("#{arg_name} is malformed")
  end

end
