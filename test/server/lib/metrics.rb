# frozen_string_literal: true

# max values used by cyberdojo/check-test-results image
# which is called from sh/coverage_in_container.sh

MAX = {
  failures: 0,
  errors: 0,
  warnings: 0,
  skips: 0,

  duration: 50,

  app: {
    lines: {
      total: 352,
      missed: 0
    },
    branches: {
      total: 60,
      missed: 1
    }
  },

  test: {
    lines: {
      total: 517,
      missed: 0
    },
    branches: {
      total: 0,
      missed: 0
    }
  }
}.freeze
