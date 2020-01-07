# frozen_string_literal: true

require 'json'

class HttpJsonArgs

  def initialize(body)
    @args = parse_json_args(body)
  rescue JSON::JSONError
    raise request_error('body is not JSON')
  end

  # - - - - - - - - - - - - - - - -

  def dispatch(path, differ)
    case path
    when '/sha'   then differ.sha(**@args)
    when '/alive' then differ.alive?(**@args)
    when '/ready' then differ.ready?(**@args)
    when '/diff'  then differ.diff(**@args)
    else raise request_error('unknown path')
    end
  rescue ArgumentError => caught
    if r = caught.message.match('(missing|unknown) keyword(s?): (.*)')
      raise request_error("#{r[1]} argument#{r[2]}: #{r[3]}")
    end
    raise
  end

  private

  def parse_json_args(body)
    args = {}
    unless body === ''
      json = JSON.parse!(body)
      unless json.is_a?(Hash)
        raise request_error('body is not JSON Hash')
      end
      # double-splat requires symbol keys
      json.each { |key,value| args[key.to_sym] = value }
    end
    args
  end

  # - - - - - - - - - - - - - - - -

  def request_error(text)
    # text uses the words 'body' and 'path'
    # to match RackDispatcher's exception keys.
    RequestError.new(text)
  end

  # - - - - - - - - - - - - - - - -

  class RequestError < RuntimeError
    def initialize(message)
      super
    end
  end

end
