# frozen_string_literal: true

$stdout.sync = true
$stderr.sync = true

require_relative '../client'
require_relative '../differ'
require 'rack'

run Client.new(External::Differ.new)
