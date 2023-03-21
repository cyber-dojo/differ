# frozen_string_literal: true

module External
  class DiskWriter
    def write(pathed_filename, content)
      File.write(pathed_filename, content)
    end
  end
end
