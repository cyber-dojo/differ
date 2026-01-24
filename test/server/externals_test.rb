# frozen_string_literal: true

require_relative 'differ_test_base'

class ExternalsTest < DifferTestBase

  test '7A9920', %w(
  | default disk is ExternalDiskWriter
  ) do
    assert_equal External::DiskWriter, disk.class
  end

  # - - - - - - - - - - - - - - - - -

  test '7A9C8F', %w(
  | default git is ExternalGitter
  ) do
    assert_equal External::Gitter, git.class
  end

  # - - - - - - - - - - - - - - - - -

  test '7A91B1', %w(
  | default shell is ExternalSheller
  ) do
    assert_equal External::Sheller, shell.class
  end

end
