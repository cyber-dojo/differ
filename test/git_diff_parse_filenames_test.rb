# frozen_string_literal: true

       'parse old & new filenames with space in both filenames' do
      'diff --git "e mpty.h" "e mpty.h"',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
       'parse old & new filenames with double-quote and space in both filenames' do
      'diff --git "li n\"ux" "em bed\"ded"',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'li n"ux',    old_filename, :old_filename
    assert_equal 'em bed"ded', new_filename, :new_filename
       'parse old & new filenames with double-quote and space only in new-filename' do
      'diff --git plain "em bed\"ded"',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'plain', old_filename, :old_filename
    assert_equal 'em bed"ded', new_filename, :new_filename
       'parse old & new filenames with double-quote and space only in old-filename' do
      'diff --git "emb ed\"ded" plain',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'emb ed"ded', old_filename, :old_filename
    assert_equal 'plain', new_filename, :new_filename
       'new_filename is nil for for deleted file' do
    old_filename, new_filename = parse_old_new_filenames(header)
       'old_filename is nil for new file' do
      'diff --git empty.h empty.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
       'parse old & new filenames for renamed file' do
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
    assert_equal 'new "name.h', new_filename, :new_filename
       'parse old & new filenames for new file in nested sub-dir' do
      'diff --git 1/2/3/empty.h 1/2/3/empty.h',
      'new file mode 100644',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
       'parse old & new filenames for renamed file in nested sub-dir' do
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
       'parse old & new filenames for renamed file across nested sub-dir' do
    old_filename, new_filename = parse_old_new_filenames(diff_lines)
  test 'AD0', %w[
  ] do
      'diff --git "s/d/f/li n\"ux" "u/i/o/em bed\"ded"',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 's/d/f/li n"ux',    old_filename, :old_filename
    assert_equal 'u/i/o/em bed"ded', new_filename, :new_filename
  test 'AD1', %w[
    and where first sub-dir is a or b which could clash
  ] do
      'diff --git "a/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
      'index 0000000..e69de29'
    old_filename, new_filename = parse_old_new_filenames(header)
    assert_equal 'a/d/f/li n"ux',      old_filename, :old_filename
    assert_equal 'b/u/i/o/em bed"ded', new_filename, :new_filename