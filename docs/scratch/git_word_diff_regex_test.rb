require 'minitest/autorun'

class GitWordDiffRegexTest < MiniTest::Test

  INSERTIONS_REGEX = /{\+.+\+}/
  DELETIONS_REGEX = /\[-.+-\]/

  def test_insertions_regex_matches_within_a_line
    src = 'xxx{+AAA+}xxx'
    r = src.match(INSERTIONS_REGEX)
    assert_equal '{+AAA+}', r[0], r
  end

  def test_insertions_regex_must_match_at_least_one_char
    src = 'xxx{++}xxx'
    r = src.match(INSERTIONS_REGEX)
    assert_nil r
  end

  def test_insertions_regex_does_not_match_across_lines
    src = [
      'xxx{+AAA',
      '+}xxx'
    ].join("\n")
    r = src.match(INSERTIONS_REGEX)
    assert_nil r
  end

  def test_deletions_regex_matches_within_a_line
    src = 'xxx[-DDD-]xxx'
    r = src.match(DELETIONS_REGEX)
    assert_equal '[-DDD-]', r[0], r
  end

  def test_deletions_regex_must_match_at_least_one_char
    src = 'xxx[--]xxx'
    r = src.match(DELETIONS_REGEX)
    assert_nil r
  end

  def test_deletions_regex_does_not_match_across_lines
    src = [
      'xxx[-DDD',
      '-]xxx'
    ].join("\n")
    r = src.match(DELETIONS_REGEX)
    assert_nil r
  end

end
