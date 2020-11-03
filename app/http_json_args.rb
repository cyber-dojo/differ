# frozen_string_literal: true
require 'json'

class HttpJsonArgs

  class RequestError < RuntimeError
    def initialize(message)
      # message uses the words 'body' and 'path'
      # to match RackDispatcher's exception keys.
      super
    end
  end

  # - - - - - - - - - - - - - - - -

  def self.dispatch(path, differ, body, params={})
    raw_args = empty?(body) ? params : json_parse(body)
    args = symbolized(raw_args)
    case path
    when '/sha'           then differ.sha(**args)
    when '/healthy'       then differ.healthy?(**args)
    when '/alive'         then differ.alive?(**args)
    when '/ready'         then differ.ready?(**args)
    when '/diff_lines2'   then differ.diff_lines2(**args)
    when '/diff_summary'  then differ.diff_summary(**args)
    else raise RequestError, 'unknown path'
    end
  rescue JSON::JSONError
    raise RequestError, 'body is not JSON'
  rescue ArgumentError => caught
    if r = caught.message.match('(missing|unknown) keyword(s?): (.*)')
      raise RequestError, "#{r[1]} argument#{r[2]}: #{r[3]}"
    end
    raise
  end

  private

  def self.empty?(body)
    body === '' || body === '{}'
  end

  def self.json_parse(body)
    json = JSON.parse!(body)
    unless json.is_a?(Hash)
      raise RequestError, 'body is not JSON Hash'
    end
    json
  end

  def self.symbolized(params)
    # double-splat requires symbol keys
    Hash[params.map{|key,value| [key.to_sym,value]}]
  end

end
