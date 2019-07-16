    header = [
       'diff --git "e mpty.h" "e mpty.h"',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
       'diff --git "li n\"ux" "em bed\"ded"',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
       'diff --git plain "em bed\"ded"',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
       'diff --git "emb ed\"ded" plain',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
      'diff --git Deleted.java Deleted.java',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
       'diff --git empty.h empty.h',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
      'diff --git old_name.h "new \"name.h"',
    header = [
       'diff --git 1/2/3/empty.h 1/2/3/empty.h',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
      'diff --git 1/2/3/old_name.h 1/2/3/new_name.h',
      'diff --git 1/2/3/old_name.h 4/5/6/new_name.h',
    header = [
       'diff --git "s/d/f/li n\"ux" "u/i/o/em bed\"ded"',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
    header = [
       'diff --git "a/d/f/li n\"ux" "b/u/i/o/em bed\"ded"',
    old_filename,new_filename = GitDiffParser.new('').parse_old_new_filenames(header)
      'diff --git "\\\\was_newfile_FIU" "\\\\was_newfile_FIU"',
      '--- "\\\\was_newfile_FIU"',
        hunks:
      'diff --git original original',
        hunks: []
      'diff --git untitled.rb untitled.rb',
      '--- untitled.rb',
        hunks:
      'diff --git "was_\\\\wa s_newfile_FIU" "\\\\was_newfile_FIU"',
        hunks: []
      'diff --git oldname newname',
        hunks: []
      'diff --git instructions instructions_new',
      '--- instructions',
      '+++ instructions_new',
        hunks:
      'diff --git lines lines',
      '--- lines',
      '+++ lines',
      'diff --git other other',
      '--- other',
      '+++ other',
        hunks:
        hunks:
  'two hunks with no newline at end of file' do
      'diff --git lines lines',
      '--- lines',
      '+++ lines',
      hunks:
  'diff one-hunk one-line' do
    my_assert_equal expected, GitDiffParser.new(lines).parse_hunk
  'diff one-hunk two-lines' do
    my_assert_equal expected, GitDiffParser.new(lines).parse_hunks
      'diff --git gapper.rb gapper.rb',
      '--- gapper.rb',
      '+++ gapper.rb',
      hunks:
      'diff --git hiker.h diamond.h',
      'index afcb4df..c0f407c 100644',
      '--- hiker.h',
      '+++ diamond.h'
    my_assert_equal lines, GitDiffParser.new(lines.join("\n")).parse_header
  'diff two hunks' do
      'diff --git test_gapper.rb test_gapper.rb',
      '--- test_gapper.rb',
      '+++ test_gapper.rb',
      hunks:
      'diff --git lines lines',
      '--- lines',
      '+++ lines',
      hunks:
      'diff --git lines lines',
      '--- lines',
      '+++ lines',
      hunks:
  'creates two hunks' do
      'diff --git lines lines',
      '--- lines',
      '+++ lines',
       hunks:
    of following file as its header_lines
      'diff --git hiker.h hiker.txt',
      'diff --git wibble.c wibble.c',
      '--- wibble.c',
      '+++ wibble.c',
        hunks: []
         hunks: