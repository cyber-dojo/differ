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
    if body === '' || body === '{}'
      args = symbolized(params)
    else
      args = parse_json_args(body)
    end
    case path
    when '/sha'           then differ.sha(**args)
    when '/alive'         then differ.alive?(**args)
    when '/ready'         then differ.ready?(**args)
    when '/diff'          then differ.diff(**args)
    when '/diff_tip_data' then differ.diff_tip_data(**args)
    when '/diff_summary'  then differ.diff_summary(**args)
    when '/diff_summary2' then differ.diff_summary2(**args)
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

  def self.symbolized(params)
    Hash[params.map{|key,value| [key.to_sym,value]}]
  end

  def self.parse_json_args(body)
    json = JSON.parse!(body)
    unless json.is_a?(Hash)
      raise RequestError, 'body is not JSON Hash'
    end
    # double-splat requires symbol keys
    Hash[json.map{|key,value| [key.to_sym,value]}]
  end

end
