# frozen_string_literal: true

require_relative 'differ'

class HtmlDemo
  def initialize
    @differ = ::External::Differ.new
  end

  def html
    src = ''
    src += sha
    src += alive?
    src += ready?
    src += diff
    src
  end

  private

  attr_reader :differ

  def sha
    duration, result = timed { differ.sha }
    pre('sha', duration, 'LightGreen', result)
  end

  def alive?
    duration, result = timed { differ.alive }
    pre('alive?', duration, 'LightGreen', result)
  end

  def ready?
    duration, result = timed { differ.ready }
    pre('ready?', duration, 'LightGreen', result)
  end

  def diff
    duration, result = timed { differ.diff_lines('5U2J18', 1, 2) }
    pre('diff_lines', duration, 'LightGreen', result)
  end

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = format('%.4f', (finished - started))
    [duration, result]
  end

  def pre(name, duration, colour = 'white', result = nil)
    border = 'border: 1px solid black;'
    padding = 'padding: 5px;'
    margin = 'margin-left: 30px; margin-right: 30px;'
    background = "background: #{colour};"
    whitespace = 'white-space: pre-wrap;'
    html = "<pre>/#{name}(#{duration}s)</pre>"
    unless result.nil?
      html += "<pre style='#{whitespace}#{margin}#{border}#{padding}#{background}'>" \
              "#{JSON.pretty_unparse(result)}" \
              '</pre>'
    end
    html
  end

  def old_files
    {
      'cyber-dojo.sh': 'blah blah',
      'hiker.c': '#include <hiker.h>',
      'deleted.txt': 'tweedle-dee'
    }
  end

  def new_files
    {
      'cyber-dojo.sh': 'blah blah blah',
      'hiker.c': '#include "hiker.h"',
      'hiker.h': "#ifndef HIKER_INCLUDED\n#endif"
    }
  end
end

puts(HtmlDemo.new.html)
