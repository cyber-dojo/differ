# frozen_string_literal: true
require_relative 'external_http'
require_relative 'external_model'
require_relative 'external_disk_writer'
require_relative 'external_gitter'
require_relative 'external_sheller'

class Externals

  def model
    @model ||= ExternalModel.new(model_http)
  end
  def model_http
    @model_http ||= ExternalHttp.new
  end

  # - - - - - - - - - - - - - - - - -

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  def git
    @git ||= ExternalGitter.new(self)
  end

  def prober
    @prober ||= Prober.new(self)
  end

  def shell
    @shell ||= ExternalSheller.new
  end

end
