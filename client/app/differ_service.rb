# frozen_string_literal: true
require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'differ_exception'

class DifferService

  def initialize(externals)
    name = 'differ_server'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJson::RequestPacker.new(externals.http, name, port)
    @http = HttpJson::ResponseUnpacker.new(requester, DifferException, keyed:false)
  end

  def sha
    @http.get(__method__, {})['sha']
  end

  def healthy?
    @http.get(__method__, {})['healthy?']
  end

  def alive?
    @http.get(__method__, {})['alive?']
  end

  def ready?
    @http.get(__method__, {})['ready?']
  end

  # - - - - - - - - - - - - - - - - - - -

  def diff(id, old_files, new_files)
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })['diff']
  end

  def diff_summary(id, was_index, now_index)
    @http.get(__method__, {
      id:id,
      was_index:was_index,
      now_index:now_index
    })
  end

end
