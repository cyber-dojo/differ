# frozen_string_literal: true
require_relative 'app_base'
require_relative 'differ'
require_relative 'prober'

class App < AppBase

  def initialize(externals)
    super(externals)
  end

   get_json(:sha,      Prober)
   get_json(:healthy?, Prober)
   get_json(:alive?,   Prober)
   get_json(:ready?,   Prober)

   get_json(:diff_lines,   Differ)
   get_json(:diff_summary, Differ)

end
