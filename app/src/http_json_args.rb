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
    @args = json_parse(body)
    unless @args.is_a?(Hash)
      raise request_error('body is not JSON Hash')
    end
  rescue JSON::JSONError
    raise request_error('body is not JSON')
  end

  # - - - - - - - - - - - - - - - -

  def dispatch(path, differ)
    case path
    when '/sha'   then no_args { differ.sha }
    when '/alive' then no_args { differ.alive? }
    when '/ready' then no_args { differ.ready? }
    when '/diff'  then differ.diff(**@args)
    else
      raise request_error('unknown path')
    end
  rescue ArgumentError => caught
    if caught.message.start_with?('missing keyword: ')
      raise request_error(caught.message)
    end
    if caught.message.start_with?('unknown keyword: ')
      raise request_error(caught.message)
    end
    raise
  end

  def no_args
    if @args === {}
      yield
    else
      raise request_error('unknown arguments')
    end
  end

  private

  def json_parse(body)
    if body === ''
      {}
    else
      JSON.parse!(body, symbolize_names:true)
    end
  end

  # - - - - - - - - - - - - - - - -

  def request_error(text)
    # Exception messages use the words 'body' and 'path'
    # to match RackDispatcher's exception keys.
    Error.new(text)
  end

end
