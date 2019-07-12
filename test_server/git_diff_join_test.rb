  # - - - - - - - - - - - - - - - - - - - - - - - -
    # $ git init
    # $ touch empty.rb
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ rm empty.rb
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = { 'empty.rb' => '' }
    new_files = {}

      'diff --git a/empty.rb b/empty.rb',
    [
        old_filename: 'empty.rb',
        new_filename: nil,
        chunks: []
    ]
    my_assert_equal expected_diffs, actual_diffs

    expected = { 'empty.rb' => [] }
    assert_join(expected, diff_lines, old_files, new_files)
    # $ git init
    # $ echo -n something > non-empty.h
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ rm non-empty.h
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = { 'non-empty.h' => 'something' }
    new_files = {}

    [
        old_filename: 'non-empty.h',
        new_filename: nil,
        chunks:
            old_start_line:1,
            deleted: [ 'something' ],
            new_start_line:0,
            added: [],
    ]
    my_assert_equal expected_diffs, actual_diffs
          line: 'something',
          type: :deleted,
          number: 1

    assert_join(expected, diff_lines, old_files, new_files)
    # $ git init
    # $ echo x > dummy
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ touch empty.h
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = {}
    new_files = { 'empty.h' => '' }
    [
        old_filename: nil,
        new_filename: 'empty.h',
        chunks: []
    ]
    my_assert_equal expected_diffs, actual_diffs
    assert_join(expected, diff_lines, old_files, new_files)
    # $ git init
    # $ echo x > dummy
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ echo -n 'something' > non-empty.c
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = {}
    new_files = { 'non-empty.c' => 'something' }
      'diff --git a/non-empty.c b/non-empty.c',
      'new file mode 100644',
      'index 0000000..a459bc2',
      '--- /dev/null',
      '+++ b/non-empty.c',
      '@@ -0,0 +1 @@',
      '+something',
      '\\ No newline at end of file'
    [
        old_filename: nil,
        new_filename: 'non-empty.c',
        chunks:
            old_start_line:0,
            deleted: [],
            new_start_line:1,
            added: [ 'something' ],
    ]
    my_assert_equal expected_diffs, actual_diffs
        { :type => :added, :line => 'something', :number => 1 }
    assert_join(expected, diff_lines, old_files, new_files)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AA6',
  'empty file is copied' do
    # $ git init
    # $ touch plain
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ mv plain copy
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = { 'plain' => '' }
    new_files = { 'copy'  => '' }
    diff_lines =
    [
      'diff --git a/plain b/copy',
      'similarity index 100%',
      'rename from plain',
      'rename to copy'
    ].join("\n")

    expected_diffs =
    [
      {
        old_filename: 'plain',
        new_filename: 'copy',
        chunks: []
      }
    ]
    actual_diffs = GitDiffParser.new(diff_lines).parse_all
    my_assert_equal expected_diffs, actual_diffs

    expected =
    {
      'copy' =>
      [
        {
          number: 1,
          type: :same,
          line: ''
        }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
    # $ git init
    # $ echo xxx > plain
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ mv plain copy
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = { 'plain' => 'xxx' }
    new_files = { 'copy' => 'xxx' }
    [
        old_filename: 'plain',
        new_filename: 'copy',
        chunks: []
    ]
    my_assert_equal expected_diffs, actual_diffs
    expected =
    {
      'copy' =>
      [
        {
          number: 1,
          type: :same,
          line: 'xxx'
        }
      ]
    }
    assert_join(expected, diff_lines, old_files, new_files)
  'existing non-empty file is changed' do
    # Note use of -n in the echoes. This is to get the \\No newline at end of file
    # $ git init
    # $ echo -n 'something' > non-empty.c
    # $ git add . && git commit -m "1" && git tag 1 HEAD
    # $ echo -n 'something changed' > non-empty.c
    # $ git add . && git commit -m "2" && git tag 2 HEAD
    # $ git diff --unified=0 --ignore-space-at-eol --indent-heuristic 1 2 --
    old_files = { 'non-empty.c' => 'something' }
    new_files = { 'non-empty.c' => 'something changed' }
      'diff --git a/non-empty.c b/non-empty.c',
      'index a459bc2..605f7ff 100644',
      '--- a/non-empty.c',
      '+++ b/non-empty.c',
      '@@ -1 +1 @@',
      '-something',
      '\\ No newline at end of file',
      '+something changed',
      '\\ No newline at end of file',
    [
        old_filename: 'non-empty.c',
        new_filename: 'non-empty.c',
        chunks:
            old_start_line:1,
            deleted: [ 'something' ],
            new_start_line:1,
            added: [ 'something changed' ],
    ]
    my_assert_equal expected_diffs, actual_diffs
        { :type => :deleted, :line => 'something', :number => 1 },
        { :type => :added, :line => 'something changed', :number => 1 }
    assert_join(expected, diff_lines, old_files, new_files)
    expected_diffs = []
    my_assert_equal expected_diffs, actual_diffs
    old_files = { 'wibble.txt' => 'content' }
    new_files = { 'wibble.txt' => 'content' }
    assert_join(expected, diff_lines, old_files, new_files)
  def assert_join(expected, diff_lines, old_files, new_files)
    actual = git_diff_join(diff_lines, old_files, new_files)
    my_assert_equal expected, actual
  include GitDiffJoin
