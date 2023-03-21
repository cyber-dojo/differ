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
      total: 101,
      missed: 0
    },
    branches: {
      total: 8,
      missed: 0
    }
  },

  test: {
    lines: {
      total: 243,
      missed: 0
    },
    branches: {
      total: 0,
      missed: 0
    }
  }
}
