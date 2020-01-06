# frozen_string_literal: true

require 'json'

class HttpJsonArgs

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  # - - - - - - - - - - - - - - - -

  def initialize(body)
    @args = parse_json_args(body)
  rescue JSON::JSONError
    raise request_error('body is not JSON')
  end

  # - - - - - - - - - - - - - - - -

  def dispatch(path, differ)
    case path
    when '/sha'   then no_args { differ.sha }
    when '/alive' then no_args { differ.alive? }
    when '/ready' then no_args { differ.ready? }
    when '/diff'  then differ.diff(**@args) # [1]
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
    result = {}
    if body != ''
      args = JSON.parse!(body)
      unless args.is_a?(Hash)
        raise request_error('body is not JSON Hash')
      end
      # [1] double-splat requires top level keys to be symbols
      args.each { |key,value| result[key.to_sym] = value }
    end
    result
  end

  # - - - - - - - - - - - - - - - -

  def no_args
    if @args === {}
      yield
    else
      plural = @args.size === 1 ? '' : 's'
      names = @args.keys.sort.join(', ')
      raise request_error("unknown argument#{plural}: #{names}")
    end
  end

  # - - - - - - - - - - - - - - - -

  def request_error(text)
    # Exception messages use the words 'body' and 'path'
    # to match RackDispatcher's exception keys.
    Error.new(text)
  end

end
