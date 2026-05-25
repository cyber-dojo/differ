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
    duration, result = timed { differ.diff_lines(was_files: WAS_FILES, now_files: now_files) }
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
    WAS_FILES.merge('hiker.sh' => hiker_sh)
  end
end

WAS_FILES = {
  'test_hiker.sh' => [
    '#!/usr/bin/env bats',
    '',
    'source ./hiker.sh',
    '',
    '@test "life the universe and everything" {',
    '  local actual=$(answer)',
    '  [ "$actual" == "42" ]',
    '}',
    ''
  ].join("\n"),
  'bats_help.txt' => [
    '',
    'bats help is online at',
    'https://github.com/bats-core/bats-core#usage',
    ''
  ].join("\n"),
  'hiker.sh' => [
    '#!/bin/bash',
    '',
    'answer()',
    '{',
    '  echo $((6 * 999))',
    '}',
    ''
  ].join("\n"),
  'cyber-dojo.sh' => [
    'chmod 700 *.sh',
    './test_*.sh',
    ''
  ].join("\n"),
  'readme.txt' => [
    'Your task is to create an LCD string representation of an',
    'integer value using a 3x3 grid of space, underscore, and',
    'pipe characters for each digit. Each digit is shown below',
    '(using a dot instead of a space)',
    '',
    '._.   ...   ._.   ._.   ...   ._.   ._.   ._.   ._.   ._.',
    '|.|   ..|   ._|   ._|   |_|   |_.   |_.   ..|   |_|   |_|',
    '|_|   ..|   |_.   ._|   ..|   ._|   |_|   ..|   |_|   ..|',
    '',
    '',
    'Example: 910',
    '',
    '._. ... ._.',
    '|_| ..| |.|',
    '..| ..| |_|',
    ''
  ].join("\n")
}.freeze

puts(HtmlDemo.new.html)
