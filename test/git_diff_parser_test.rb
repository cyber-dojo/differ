    diff = [
                type: :deleted,
    assert_equal expected, GitDiffParser.new(diff,lines:true).parse_all
    diff = [
                type: :deleted,
    assert_equal expected, GitDiffParser.new(diff,lines:true).parse_all
    diff = [
                type: :deleted,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
    diff = [
                type: :renamed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
    diff = [
                type: :renamed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
    diff = [
                type: :renamed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
    diff = [
                type: :changed,
                type: :changed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_all
    diff = [
              type: :changed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
    diff = [
              type: :changed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
    diff = [
              type: :changed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
    diff = [
    assert_equal diff, GitDiffParser.new(diff.join("\n")).parse_header
    diff = [
              type: :renamed,
    assert_equal expected, GitDiffParser.new(diff, lines:true).parse_one
  include GitDiffParserLib
