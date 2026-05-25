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
    duration, result = timed { differ.diff_lines(was_files: was_files, now_files: now_files) }
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

  def was_files
    {
      'test_hiker.sh' => "#!/usr/bin/env bats\n\nsource ./hiker.sh\n\n@test \"life the universe and everything\" {\n  local actual=$(answer)\n  [ \"$actual\" == \"42\" ]\n}\n",
      'bats_help.txt' => "\nbats help is online at\nhttps://github.com/bats-core/bats-core#usage\n",
      'hiker.sh' => "#!/bin/bash\n\nanswer()\n{\n  echo $((6 * 999))\n}\n",
      'cyber-dojo.sh' => "chmod 700 *.sh\n./test_*.sh\n",
      'readme.txt' => "Your task is to create an LCD string representation of an\ninteger value using a 3x3 grid of space, underscore, and\npipe characters for each digit. Each digit is shown below\n(using a dot instead of a space)\n\n._.   ...   ._.   ._.   ...   ._.   ._.   ._.   ._.   ._.\n|.|   ..|   ._|   ._|   |_|   |_.   |_.   ..|   |_|   |_|\n|_|   ..|   |_.   ._|   ..|   ._|   |_|   ..|   |_|   ..|\n\n\nExample: 910\n\n._. ... ._.\n|_| ..| |.|\n..| ..| |_|\n"
    }
  end

  def now_files
    hiker_sh = [
      '#!/bin/bash',
      '',
      'answer()',
      '{',
      '  echo $((6 * 999sss))',
      '}',
      ''
    ].join("\n")
    was_files.merge('hiker.sh' => hiker_sh)
  end
end

puts(HtmlDemo.new.html)
