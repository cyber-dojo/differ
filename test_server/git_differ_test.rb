    now_files = { }
    @old_files = { }
    @new_files = { }
    @old_files = { 'hiker.h' => '' }
    @new_files = { }
      'diff --git hiker.h hiker.h',
    @old_files = { 'sub-dir/hiker.h' => '' }
    @new_files = { }
      'diff --git sub-dir/hiker.h sub-dir/hiker.h',
    @old_files = { 'd1/d2/d3/d4/hiker.h' => '' }
    @new_files = { }
      'diff --git d1/d2/d3/d4/hiker.h d1/d2/d3/d4/hiker.h',
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
      'diff --git hiker.h hiker.h',
      '--- hiker.h',
    @old_files = { 'dir/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
      'diff --git dir/hiker.h dir/hiker.h',
      '--- dir/hiker.h',
    @old_files = { '1/2/3/4/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { }
      'diff --git 1/2/3/4/hiker.h 1/2/3/4/hiker.h',
      '--- 1/2/3/4/hiker.h',
    @old_files = { 'hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { 'hiker.h' => '' }
      'diff --git hiker.h hiker.h',
      '--- hiker.h',
      '+++ hiker.h',
    @old_files = { '3/2/1/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { '3/2/1/hiker.h' => '' }
      'diff --git 3/2/1/hiker.h 3/2/1/hiker.h',
      '--- 3/2/1/hiker.h',
      '+++ 3/2/1/hiker.h',
    @old_files = { '1/hiker.h' => "a\nb\nc\nd\n" }
    @new_files = { '1/hiker.h' => '' }
      'diff --git 1/hiker.h 1/hiker.h',
      '--- 1/hiker.h',
      '+++ 1/hiker.h',
    @old_files = { }
    @new_files = { 'diamond.h' => '' }
      'diff --git diamond.h diamond.h',
    @old_files = { }
    @new_files = { 'sub-dir/diamond.h' => '' }
      'diff --git sub-dir/diamond.h sub-dir/diamond.h',
    @old_files = { }
    @new_files = { '1/2/3/4/diamond.h' => '' }
      'diff --git 1/2/3/4/diamond.h 1/2/3/4/diamond.h',
    @old_files = { }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
      'diff --git diamond.h diamond.h',
      '+++ diamond.h',
    @old_files = { }
    @new_files = { '4/diamond.h' => "a\nb\nc\nd" }
      'diff --git 4/diamond.h 4/diamond.h',
      '+++ 4/diamond.h',
    @old_files = { }
    @new_files = { '1/2/3/4/diamond.h' => "a\nb\nc\nd" }
      'diff --git 1/2/3/4/diamond.h 1/2/3/4/diamond.h',
      '+++ 1/2/3/4/diamond.h',
    @old_files = { 'diamond.h' => '' }
    @new_files = { 'diamond.h' => '' }
    @old_files = { 'x/diamond.h' => '' }
    @new_files = { 'x/diamond.h' => '' }
    @old_files = { 'x/y/z/diamond.h' => '' }
    @new_files = { 'x/y/z/diamond.h' => '' }
    @old_files = { 'diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
    @old_files = { 'd/diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'd/diamond.h' => "a\nb\nc\nd" }
    @old_files = { 'w/e/r/diamond.h' => "a\nb\nc\nd" }
    @new_files = { 'w/e/r/diamond.h' => "a\nb\nc\nd" }
    @old_files = { 'diamond.h' => 'a' }
    @new_files = { 'diamond.h' => 'b' }
      'diff --git diamond.h diamond.h',
      '--- diamond.h',
      '+++ diamond.h',
    @old_files = { 'x/diamond.h' => 'a' }
    @new_files = { 'x/diamond.h' => 'b' }
      'diff --git x/diamond.h x/diamond.h',
      '--- x/diamond.h',
      '+++ x/diamond.h',
  'with each hunk in its own indexed section' do
    @old_files = {
    @new_files = {
      'diff --git diamond.h diamond.h',
      '--- diamond.h',
      '+++ diamond.h',
      '@@ -4 +4 @@',
      '@@ -6 +6 @@',
    with each hunk in its own indexed section
    @old_files = {
    @new_files = {
      'diff --git p/diamond.h p/diamond.h',
      '--- p/diamond.h',
      '+++ p/diamond.h',
      '@@ -4 +4 @@',
      '@@ -6 +6 @@',
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nc\nd" }
      'diff --git hiker.h diamond.h',
  # - - - - - - - - - - - - - - - - - - - -

    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'x/diamond.h' => "a\nb\nc\nd" }
      'diff --git hiker.h x/diamond.h',
  # - - - - - - - - - - - - - - - - - - - -

    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'x/y/z/diamond.h' => "a\nb\nc\nd" }
      'diff --git hiker.h x/y/z/diamond.h',
  # - - - - - - - - - - - - - - - - - - - -

    @old_files = { '1/2/3/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'x/y/z/diamond.h' => "a\nb\nc\nd" }
      'diff --git 1/2/3/hiker.h x/y/z/diamond.h',
    @old_files = { 'hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'diamond.h' => "a\nb\nX\nd" }
      'diff --git hiker.h diamond.h',
      '--- hiker.h',
      '+++ diamond.h',
      '@@ -3 +3 @@ b',
  # - - - - - - - - - - - - - - - - - - - -

    @old_files = { '1/2/hiker.h'   => "a\nb\nc\nd" }
    @new_files = { 'x/y/diamond.h' => "a\nb\nX\nd" }
      'diff --git 1/2/hiker.h x/y/diamond.h',
      '--- 1/2/hiker.h',
      '+++ x/y/diamond.h',
      '@@ -3 +3 @@ b',
    @old_files = {
    @new_files = {
      'diff --git a/hiker.h a/hiker.txt',
      'diff --git wibble.c wibble.c',
      '--- wibble.c',
      '+++ wibble.c',
      '@@ -2,0 +3 @@ xyz',
    lines += [ '' ] unless lines === []
    actual = GitDiffer.new(self).diff(@old_files, @new_files)
    my_assert_equal expected, actual