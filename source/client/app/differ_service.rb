# frozen_string_literal: true
require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'differ_exception'

class DifferService

  def initialize(externals)
    name = 'differ-server'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJson::RequestPacker.new(externals.http, name, port)
    @http = HttpJson::ResponseUnpacker.new(requester, DifferException)
  end

  def sha
    @http.get(__method__, {})
  end

  def alive?
    @http.get(__method__, {})
  end

  def ready?
    @http.get(__method__, {})
  end

  def diff(id, old_files, new_files)
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

  def diff_tip_data(id, old_files, new_files)
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

end
