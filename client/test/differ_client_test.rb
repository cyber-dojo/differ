require_relative 'client_test_base'
require 'cgi'

class DifferClientTest < ClientTestBase

  def self.id58_prefix
    '2q0'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'jj9', '/diff_summary uses proper GET query args' do
    hostname = 'differ_server'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJsonHash::Requester.new(hostname, port)
    http = HttpJsonHash::Unpacker.new(requester)
    args = { id:'RNCzUr', was_index:8, now_index:9 }
    encoded = args.map{|name,value|
      "#{name}=#{CGI.escape(value.to_s)}"
    }.join('&')
    path = "diff_summary?#{encoded}"
    actual = http.get(path, {})
    expected = [
      { 'type' => 'deleted',
        'old_filename' => "readme.txt",
        'new_filename' => nil,
        'line_counts' => { 'added' => 0, 'deleted' => 14, 'same' => 0 }
      },
      {
        "type" => "unchanged",
        "old_filename" => "test_hiker.sh",
        "new_filename" => "test_hiker.sh",
        "line_counts" => { "same"=>8, "added"=>0, "deleted"=>0 }
      },
      { "type" => "unchanged",
        "old_filename" => "bats_help.txt",
        "new_filename" => "bats_help.txt",
        "line_counts" => { "same"=>3, "added"=>0, "deleted"=>0 }
      },
      { "type" => "unchanged",
        "old_filename" => "hiker.sh",
        "new_filename" => "hiker.sh",
        "line_counts" => { "same"=>6, "added"=>0, "deleted"=>0 }
      },
      { "type" => "unchanged",
        "old_filename" => "cyber-dojo.sh",
        "new_filename" => "cyber-dojo.sh",
        "line_counts" => { "same"=>2, "added"=>0, "deleted"=>0 }
      },
      { "type" => "unchanged",
        "old_filename" => "sub_dir/empty.file.rename",
        "new_filename" => "sub_dir/empty.file.rename",
        "line_counts" => { "same"=>1, "added"=>0, "deleted"=>0 }
      }
    ]
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - -
  # >10K query was a problem for thin at one time
  # - - - - - - - - - - - - - - - - - - - -

  test '347',
  '>10K query is not rejected by web server' do
    @old_files = { 'wibble.h' => 'X'*45*1024 }
    @new_files = {}
    id,was_index,now_index = *run_diff_prepare
    differ.diff_summary(id, was_index, now_index)
  end

  test '348',
  '>10K query in nested sub-dir is not rejected by web-server' do
    @old_files = { 'gh/jk/wibble.h' => 'X'*45*1024 }
    @new_files = {}
    id,was_index,now_index = *run_diff_prepare
    differ.diff_summary(id, was_index, now_index)
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '944', 'sha 200' do
    sha = differ.sha
    assert_equal 40, sha.size, 'sha.size'
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch), ch
    end
  end

  test '945', 'probes 200' do
    assert differ.healthy?.is_a?(TrueClass)
    assert differ.alive?.is_a?(TrueClass)
    assert differ.ready?.is_a?(TrueClass)
  end

  # - - - - - - - - - - - - - - - - - - - -
  # failure cases
  # - - - - - - - - - - - - - - - - - - - -

  test '7C0', %w( calling unknown method raises ) do
    hostname = 'differ_server'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJsonHash::Requester.new(hostname, port)
    http = HttpJsonHash::Unpacker.new(requester)
    error = assert_raises(RuntimeError) { http.get(:shar, {"x":42}) }
    json = JSON.parse(error.message)
    assert_equal '/shar', json['path']
    assert_equal '{"x":42}', json['body']
    assert_equal 'DifferService', json['class']
    assert_equal 'unknown path', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete file
  # - - - - - - - - - - - - - - - - - - - -

  test '313',
  'deleted empty file' do
    @old_files = { 'hiker.h' => '' }
    @new_files = { }
    assert_diff(
      {
        "type" => "deleted",
        "old_filename" => 'hiker.h',
        "new_filename" => nil,
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=> 0 },
        "lines" => []
      }
    )
    assert_existing_diff_summary('RNCzUr',3,4) { [
      :deleted, 'empty.file', nil, 0,0,0,
      :unchanged, "test_hiker.sh", "test_hiker.sh", 0,0,8,
      :unchanged, "bats_help.txt", "bats_help.txt", 0,0,3,
      :unchanged, "hiker.sh"     , "hiker.sh"     , 0,0,6,
      :unchanged, "cyber-dojo.sh", "cyber-dojo.sh", 0,0,2,
      :unchanged, "readme.txt"   , "readme.txt"   , 0,0,14
    ] }
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '314',
  'deleted empty file in nested sub-dir' do
    @old_files = { '6/7/8/hiker.h' => '' }
    @new_files = { }
    assert_diff(
      {
        "type" => "deleted",
        "old_filename" => '6/7/8/hiker.h',
        "new_filename" => nil,
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=> 0 },
        "lines" => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FE9',
  'deleted non-empty file shows as all lines deleted' do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
    assert_diff(
      {
        "type" => "deleted",
        "old_filename" => 'hiker.h',
        "new_filename" => nil,
        "line_counts" => { "added"=>0, "deleted"=>4, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
    assert_existing_diff_summary('RNCzUr',8,9) {
      [
        :deleted, 'readme.txt', nil, 0,14,0,
        :unchanged, "test_hiker.sh"            , "test_hiker.sh"            , 0,0,8,
        :unchanged, "bats_help.txt"            , "bats_help.txt"            , 0,0,3,
        :unchanged, "hiker.sh"                 , "hiker.sh"                 , 0,0,6,
        :unchanged, "cyber-dojo.sh"            , "cyber-dojo.sh"            , 0,0,2,
        :unchanged, "sub_dir/empty.file.rename", "sub_dir/empty.file.rename", 0,0,1
      ]
    }
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FEA',
  'deleted non-empty file in nested sub-dir shows as all lines deleted' do
    @old_files = { '4/5/6/7/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
    assert_diff(
      {
        "type" => "deleted",
        "old_filename" => '4/5/6/7/hiker.h',
        "new_filename" => nil,
        "line_counts" => { "added"=>0, "deleted"=>4, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # delete content
  # - - - - - - - - - - - - - - - - - - - -

  test 'B67',
  'all lines deleted but file not deleted',
  'shows as all lines deleted' do
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'hiker.h' => '' }
    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 'hiker.h',
        "new_filename" => 'hiker.h',
        "line_counts" => { "added"=>0, "deleted"=>4, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd'),
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B68',
  'all lines deleted but nested sub-dir file not deleted',
  'shows as all lines deleted' do
    @old_files = { 'r/t/y/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'r/t/y/hiker.h' => '' }
    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 'r/t/y/hiker.h',
        "new_filename" => 'r/t/y/hiker.h',
        "line_counts" => { "added"=>0, "deleted"=>4, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a'),
          deleted(2, 'b'),
          deleted(3, 'c'),
          deleted(4, 'd'),
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # new file
  # - - - - - - - - - - - - - - - - - - - -

  test '95F',
  %w( created new empty file ) do
    @old_files = { }
    @new_files = { 'diamond.h' => '' }
    assert_diff(
      {
        "type" => "created",
        "old_filename" => nil,
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=> 0 },
        "lines" => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '960',
  %w( created empty file in nested sub-dir ) do
    @old_files = { }
    @new_files = { 'a/b/c/diamond.h' => '' }
    assert_diff(
      {
        "type" => "created",
        "old_filename" => nil,
        "new_filename" => 'a/b/c/diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=> 0 },
        "lines" => []
      }
    )
    assert_existing_diff_summary('RNCzUr',2,3) {
      [
        :created, nil, 'empty.file', 0,0,0,
        :unchanged, "test_hiker.sh", "test_hiker.sh", 0,0,8,
        :unchanged, "bats_help.txt", "bats_help.txt", 0,0,3,
        :unchanged, "hiker.sh"     , "hiker.sh"     , 0,0,6,
        :unchanged, "cyber-dojo.sh", "cyber-dojo.sh", 0,0,2,
        :unchanged, "readme.txt"   , "readme.txt"   , 0,0,14
      ]
    }
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2C3',
  %w( created non-empty file ) do
    @old_files = { }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        "type" => "created",
        "old_filename" => nil,
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>4, "deleted"=>0, "same"=> 0 },
        "lines" => [
          section(0),
          added(1, 'a'),
          added(2, 'b'),
          added(3, 'c'),
          added(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '2C4',
  %w( created non-empty file in nested sub-dir ) do
    @old_files = { }
    @new_files = { 'q/w/e/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        "type" => "created",
        "old_filename" => nil,
        "new_filename" => 'q/w/e/diamond.h',
        "line_counts" => { "added"=>4, "deleted"=>0, "same"=> 0 },
        "lines" => [
          section(0),
          added(1, 'a'),
          added(2, 'b'),
          added(3, 'c'),
          added(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # change
  # - - - - - - - - - - - - - - - - - - - -

  test 'E3E',
  %w( changed non-empty file ) do
    @old_files = { 'diamond.h' => 'a' }
    @new_files = { 'diamond.h' => 'b' }
    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 'diamond.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a'),
          added(  1, 'b')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'E3F',
  %w( changed non-empty file in nested sub-dir ) do
    @old_files = { 't/y/u/diamond.h' => 'a1' }
    @new_files = { 't/y/u/diamond.h' => 'b2' }
    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 't/y/u/diamond.h',
        "new_filename" => 't/y/u/diamond.h',
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=> 0 },
        "lines" => [
          section(0),
          deleted(1, 'a1'),
          added(  1, 'b2')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B9E',
  'changed non-empty file shows as deleted and added lines',
  'with each hunk in its own indexed section' do
    @old_files = {
      'diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>', # no g
          '',
          'void diamond(char)', # no ;
          '',
          '#endif',
        ].join("\n")
    }
    @new_files = {
      'diamond.h' =>
        [
        '#ifndef DIAMOND',
        '#define DIAMOND',
        '',
        '#include <string>',
        '',
        'void diamond(char);',
        '',
        '#endif',
        ].join("\n")
    }

    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 'diamond.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>2, "deleted"=>2, "same"=>6 },
        "lines" => [
          same(   1, '#ifndef DIAMOND'),
          same(   2, '#define DIAMOND'),
          same(   3, ''),

          section(0),
          deleted(4, '#include <strin>'),
          added(  4, '#include <string>'),
          same(   5, ''),

          section(1),
          deleted(6, 'void diamond(char)'),
          added(  6, 'void diamond(char);'),
          same(   7, ''),
          same(   8, '#endif'),
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'B9F',
  'changed non-empty file in nested sub-dir shows as deleted and added lines',
  'with each hunk in its own indexed section' do
    @old_files = {
      'a/b/c/diamond.h' =>
        [
          '#ifndef DIAMOND',
          '#define DIAMOND',
          '',
          '#include <strin>', # no g
          '',
          'void diamond(char)', # no ;
          '',
          '#endif',
        ].join("\n")
    }
    @new_files = {
      'a/b/c/diamond.h' =>
        [
        '#ifndef DIAMOND',
        '#define DIAMOND',
        '',
        '#include <string>',
        '',
        'void diamond(char);',
        '',
        '#endif',
        ].join("\n")
    }

    assert_diff(
      {
        "type" => "changed",
        "old_filename" => 'a/b/c/diamond.h',
        "new_filename" => 'a/b/c/diamond.h',
        "line_counts" => { "added"=>2, "deleted"=>2, "same"=>6 },
        "lines" => [
          same(   1, '#ifndef DIAMOND'),
          same(   2, '#define DIAMOND'),
          same(   3, ''),

          section(0),
          deleted(4, '#include <strin>'),
          added(  4, '#include <string>'),
          same(   5, ''),

          section(1),
          deleted(6, 'void diamond(char)'),
          added(  6, 'void diamond(char);'),
          same(   7, ''),
          same(   8, '#endif'),
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # renamed file
  # - - - - - - - - - - - - - - - - - - - -

  test 'E50',
  '100% identical renamed file' do
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        "type" => "renamed",
        "old_filename" => 'hiker.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>4 },
        "lines" => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
    assert_existing_diff_summary('RNCzUr',5,6) {
      [
        :renamed, 'empty.file', 'empty.file.rename', 0,0,0,
        :unchanged, "test_hiker.sh", "test_hiker.sh", 0,0,8,
        :unchanged, "bats_help.txt", "bats_help.txt", 0,0,3,
        :unchanged, "hiker.sh"     , "hiker.sh"     , 0,0,6,
        :unchanged, "cyber-dojo.sh", "cyber-dojo.sh", 0,0,2,
        :unchanged, "readme.txt"   , "readme.txt"   , 0,0,14
      ]
    }
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'E51',
  '100% identical renamed file in nested sub-dir' do
    @old_files = { 'a/f/d/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/f/d/diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        "type" => "renamed",
        "old_filename" => 'a/f/d/hiker.h',
        "new_filename" => 'a/f/d/diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>4 },
        "lines" => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FDB',
  '<100% identical rename' do
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      {
        "type" => "renamed",
        "old_filename" => 'hiker.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=>3 },
        "lines" => [
          same(   1, 'a'),
          same(   2, 'b'),
          section(0),
          deleted(3, 'c'),
          added(  3, 'X'),
          same(   4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test 'FDC',
  '<100% identical renamed in nested sub-dir' do
    @old_files = { 'a/b/c/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'a/b/c/diamond.h' => "a\nb\nX\nd" }
    assert_diff(
      {
        "type" => "renamed",
        "old_filename" => 'a/b/c/hiker.h',
        "new_filename" => 'a/b/c/diamond.h',
        "line_counts" => { "added"=>1, "deleted"=>1, "same"=>3 },
        "lines" => [
          same(   1, 'a'),
          same(   2, 'b'),
          section(0),
          deleted(3, 'c'),
          added(  3, 'X'),
          same(   4, 'd')
        ]
     }
   )
  end

  # - - - - - - - - - - - - - - - - - - - -
  # unchanged files
  # - - - - - - - - - - - - - - - - - - - -

  test 'AEC',
  'unchanged empty files' do
    @old_files = { 'diamond.h' => '' }
    @new_files = { 'diamond.h' => '' }
    assert_diff(
      {
        "type" => "unchanged",
        "old_filename" => 'diamond.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>0 },
        "lines" => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '7FF',
  'unchanged empty-file in nested sub-dir' do
    @old_files = { 'w/e/r/diamond.h' => '' }
    @new_files = { 'w/e/r/diamond.h' => '' }
    assert_diff(
      {
        "type" => "unchanged",
        "old_filename" => 'w/e/r/diamond.h',
        "new_filename" => 'w/e/r/diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>0 },
        "lines" => []
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '365',
  'unchanged non-empty file' do
    @old_files = { 'diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    assert_diff(
      {
        "type" => "unchanged",
        "old_filename" => 'diamond.h',
        "new_filename" => 'diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>4 },
        "lines" => [
          same(1, 'a'),
          same(2, 'b'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '366',
  'unchanged non-empty file in nested sub-dir shows as all lines same' do
    @old_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    @new_files = { 'r/t/y/diamond.h' => "a\nbb\nc\nd" }
    assert_diff(
      {
        "type" => "unchanged",
        "old_filename" => 'r/t/y/diamond.h',
        "new_filename" => 'r/t/y/diamond.h',
        "line_counts" => { "added"=>0, "deleted"=>0, "same"=>4 },
        "lines" => [
          same(1, 'a'),
          same(2, 'bb'),
          same(3, 'c'),
          same(4, 'd')
        ]
      }
    )
  end

  private

  def assert_diff(expected)
    assert_diff_lines(expected)
    expected.delete("lines")
    assert_diff_summary(expected)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff_lines(expected)
    id,was_index,now_index = *run_diff_prepare
    diff = differ.diff_lines(id, was_index, now_index)
    assert diff.include?(expected), diff
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_diff_summary(expected)
    id,was_index,now_index = *run_diff_prepare
    diff = differ.diff_summary(id, was_index, now_index)
    assert diff.include?(expected), diff
  end

  # - - - - - - - - - - - - - - - - - - - -

  def run_diff_prepare
    id = model.kata_create(starter_manifest)['kata_create']
    kata_ran_tests(id, was_index=1, @old_files)
    kata_ran_tests(id, now_index=2, @new_files)
    [id, was_index, now_index]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, index, files)
    model.kata_ran_tests(
      id,
      index,
      plain(files),
      stdout={
        'content' => 'this is stdout',
        'truncated' => false
      },
      stderr={
        'content' => 'this is stderr',
        'truncated' => false
      },
      status='0',
      summary = {
        'duration' => 0.457764,
        'colour' => 'green',
        'predicted' => 'none'
      }
    )
  end

  # - - - - - - - - - - - - - - - - - - - -

  def starter_manifest
    manifest = model.kata_manifest('5U2J18') # from test-data copied into saver
    %w( id created group_id group_index ).each {|key| manifest.delete(key) }
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - -

  def plain(files)
    files.map{|filename,content|
      [filename,{
        'content' => content,
        'truncated' => false
      }]
    }.to_h
  end

  # - - - - - - - - - - - - - - - - - - - -

  def assert_existing_diff_summary(id, was_index, now_index)
    expected = *yield.each_slice(6).to_a.map do |diff|
      { 'type' => diff[0].to_s,
        'old_filename' => diff[1],
        'new_filename' => diff[2],
        'line_counts' => { 'added' => diff[3], 'deleted' => diff[4], 'same' => diff[5] }
      }
    end
    actual = differ.diff_summary(id, was_index, now_index)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - - - - -

  def deleted(number, text)
    line(text, 'deleted', number)
  end

  def same(number, text)
    line(text, 'same', number)
  end

  def added(number, text)
    line(text, 'added', number)
  end

  def line(text, type, number)
    { 'line' => text, 'type' => type, 'number' => number }
  end

  def section(index)
    { 'type' => 'section', 'index' => index }
  end

end
