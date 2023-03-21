# max values used by cyberdojo/check-test-results image
# which is called from sh/test_in_containers.sh

MAX = {
  failures: 0,
  errors: 0,
  warnings: 0,
  skips: 0,

  duration: 50,

  app: {
    lines: {
      total: 353,
      missed: 0
    },
    branches: {
      total: 56,
      missed: 1
    }
  },

  test: {
    lines: {
      total: 525,
      missed: 0
    },
    branches: {
      total: 0,
      missed: 0
    }
  }
}.freeze
