# frozen_string_literal: true
require_relative 'external/disk_writer'
require_relative 'external/gitter'
require_relative 'external/http'
require_relative 'external/model'
require_relative 'external/sheller'

class Externals

  def disk
    @disk ||= External::DiskWriter.new
  end

  def git
    @git ||= External::Gitter.new(self)
  end

  def shell
    @shell ||= External::Sheller.new
  end

  # - - - - - - - - - - - - - - - - -

  def model
    @model ||= External::Model.new(self)
  end
  def model_http
    @model_http ||= External::Http.new
  end

end
